create unique index if not exists main_editor_book
on Book_Employee (id_book)
where main_editor = true;