--триггер для таблицы контрактов, на проверку манагеров
create or replace function check_manager()
returns trigger as $$
begin
	if not exists (
		select 1 from Employee
		where id_employee = new.id_manager and employee_position = 'manager'
	) then
		raise exception 'Employee must be a manager!!!';
	end if;
	return new;
end;
$$ language plpgsql;

create trigger check_manager
before insert or update of id_manager on Contract
for each row
execute function check_manager();

--триггер для таблицы книга-сотрудник, на проверку редактора
create or replace function check_editor()
returns trigger as $$
begin
    if not exists (
        select 1 from Employee
        where id_employee = new.id_editor and employee_position = 'editor'
    ) then
        raise exception 'Employee must be a editor!!!';
    end if;
    return new;
end;
$$ language plpgsql;

create trigger check_editor
before insert or update of id_editor on Book_Employee
for each row
execute function check_editor();

--триггер на создание бекапа перед тем как пользователь введет команду delete
create or replace function backup_delete()
returns trigger as $$
declare
    backup_file text := '/exports/' || tg_table_name || '_delete_' || to_char(now(), 'YYYYMMDD_HH24MISS') || '.csv';
begin
    execute format('copy %I to %L with (format csv, header, delimiter '','')', tg_table_name, backup_file);
    return old;
end;
$$ language plpgsql;

do $$
declare
    t text;
begin
    for t in
        select table_name
        from information_schema.tables
        where table_schema = 'public'
    loop
        execute format(
            'drop trigger if exists trg_backup_delete on %I; ' ||
            'create trigger trg_backup_delete before delete on %I ' ||
            'for each statement execute function backup_delete();',
            t, t
        );
    end loop;
end;
$$;

--создание триггре для создание бекапа перед тем, как вводим truncate
create or replace function backup_truncate()
returns trigger as $$
declare
    backup_file text := '/exports/' || tg_table_name || '_truncate_' || to_char(now(), 'YYYYMMDD_HH24MISS') || '.csv';
begin
    execute format(
        'copy %I to %L with (format csv, header, delimiter '','')',
        tg_table_name, backup_file
    );
    return null;
end;
$$ language plpgsql;

do $$
declare
    t text;
begin
    for t in
        select table_name from information_schema.tables where table_schema = 'public'
    loop
        execute format(
            'drop trigger if exists trg_backup_truncate on %I;
             create trigger trg_backup_truncate
             before truncate on %I
             for each statement execute function backup_truncate();',
            t, t
        );
    end loop;
end;
$$;

--создание триггре для создание бекапа перед тем, как вводим drop
create or replace function safe_drop(table_name text)
returns void as $$
declare
    backup_file text;
begin
    backup_file := '/exports/' || table_name || '_drop_' || to_char(now(), 'YYYYMMDD_HH24MISS') || '.csv';
    execute format(
        'copy %I to %L with (format csv, header, delimiter '','')',
        table_name, backup_file
    );
    execute format('drop table if exists %I cascade', table_name);
end;
$$ language plpgsql;