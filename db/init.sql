create table if not exists Author (
	id_author bigserial primary key,
	first_name text not null,
	last_name text not null,
	patronymic text
);

create table if not exists Employee (
	id_employee bigserial primary key,
	first_name text not null,
	last_name text not null,
	patronymic text,
	employee_position text not null
		check (employee_position in ('manager', 'editor'))
);

--здесь надо добавить триггер для проверки, что сотрудник является манагером
create table if not exists Contract (
	id_contract bigserial primary key,
	id_manager bigint not null,
	price decimal(10, 2) not null,
	date_sign date not null,
	foreign key (id_manager) references Employee(id_employee) on delete cascade
);

create table if not exists Contract_Author (
    id_author bigint not null,
    id_contract bigint not null,
    primary key (id_author, id_contract),
    foreign key (id_author) references Author(id_author) on delete cascade,
    foreign key (id_contract) references Contract(id_contract) on delete cascade
);

create table if not exists Book (
    id_book bigserial primary key,
    id_contract bigint not null unique,
    book_name text not null,
    genre text
		check (genre in ('Fantasy', 'Science Fiction', 'Mystery', 'Romance', 'Thriller')),
	foreign key (id_contract) references Contract(id_contract) on delete cascade
);

create table if not exists Book_Author (
    id_book bigint not null,
    id_author bigint not null,
    fee decimal(10, 2),
    author_order integer not null
        check (author_order > 0),
    unique (id_book, author_order),
    primary key (id_book, id_author),
    foreign key (id_book) references Book(id_book) on delete cascade,
    foreign key (id_author) references Author(id_author) on delete cascade
);

--здесь надо добавить триггер для проверки, что сотрудник редактор
create table if not exists Book_Employee (
    id_book bigint not null,
    id_editor bigint not null,
    main_editor boolean default false,
    primary key (id_book, id_editor),
    foreign key (id_book) references Book(id_book) on delete cascade,
    foreign key (id_editor) references Employee(id_employee) on delete cascade
);

create table if not exists Customer (
	id_customer bigserial primary key,
	first_name text not null,
	last_name text not null,
	patronymic text,
	address text not null,
	phone bigint
);

create table if not exists Orders (
	id_order bigserial primary key,
	id_customer bigint not null,
	status text not null
		check (status in ('ready', 'processing', 'accepted', 'rejected', 'in progress')),
	amount decimal(10, 2),
	foreign key (id_customer) references Customer(id_customer) on delete cascade
);

create table if not exists Orders_Book (
    id_order bigint not null,
    id_book bigint not null,
    price decimal(10, 2) not null,
    quantity integer not null
        check (quantity > 0),
    primary key (id_order, id_book),
    foreign key (id_order) references Orders(id_order) on delete cascade,
    foreign key (id_book) references Book(id_book) on delete cascade
);