insert into author(first_name, last_name, patronymic)
values
	('Иван', 'Иванов', 'Иванович'),
	('Иван', 'Петров', 'Сергеевич'),
	('Анна', 'Горная', ''),
	('Петр', 'Стрельцов', 'Давидович'),
	('Светлана', 'Белая', 'Николаевна')
;

insert into employee(first_name, last_name, patronymic, employee_position)
values
    ('Алексей', 'Кузнецов', 'Ильич', 'manager'),
    ('Марина', 'Соколова', '', 'manager'),
    ('Ирина', 'Мельник', 'Павловна', 'editor'),
    ('Никита', 'Гордеев', '', 'editor'),
    ('Дмитрий', 'Орлов', 'Сергеевич', 'manager')
;

insert into contract(id_manager, price, date_sign)
values
    (1, 1500.00, '2025-02-01'),
    (1, 1800.00, '2025-03-10'),
    (2, 1200.00, '2025-03-15'),
    (1, 950.00,  '2025-04-01'),
    (5, 2000.00, '2025-04-20')
;

insert into book(id_contract, book_name, genre)
values
	(1, 'Дюна', 'Science Fiction'),
	(2, 'Добрые предзнаменования', 'Fantasy'),
	(3, 'Гордость и предубеждение', 'Romance'),
	(4, 'Молчание ягнят', 'Thriller'),
	(5, 'Зов кукушки', 'Mystery')
;

insert into book_author(id_book, id_author, fee, author_order)
values
	(1, 1, 70000.00, 1),
	(2, 2, 50000.50, 2),
	(2, 5, 55000.00, 1),
	(3, 3, 20500.00, 1),
	(4, 1, 65000.00, 1),
	(4, 3, 40000.00, 2),
	(5, 1, 10000.80, 1)
;

insert into contract_author (id_author, id_contract)
values
	(1, 1),
	(2, 2),
	(5, 2),
	(3, 3),
	(1, 4),
	(3, 4),
	(1, 5)
;

insert into book_employee(id_book, id_editor, main_editor)
values
	(1, 3, 'true'),
	(2, 3, 'true'),
	(2, 4, 'false'),
	(3, 4, 'true'),
	(4, 4, 'true'),
	(5, 3, 'true'),
	(5, 4, 'false')
;

insert into customer(first_name, last_name, patronymic, address, phone)
values
	('Иван', 'Петров', 'Сергеевич', 'г. Москва, ул. Тверская, д. 25, кв. 14', 79151234567),
	('Екатерина', 'Смирнова', '', 'г. Санкт-Петербург, Невский пр-т, д. 100, кв. 56', 79167654321),
	('Алексей', 'Козлов', 'Владимирович', 'г. Новосибирск, ул. Ленина, д. 15, кв. 89', 79182345678),
	('Ольга', 'Новикова', 'Игоревна', 'г. Екатеринбург, пр-т Космонавтов, д. 42, кв. 33', 79193456789),
	('Дмитрий', 'Васильев', '', 'г. Казань, ул. Баумана, д. 78, кв. 21', 79174567890)
;

insert into orders(id_customer, status, amount)
values
	(1, 'ready', 2540.50),
	(3, 'processing', 1875.00),
	(3, 'accepted', 3200.75),
	(5, 'in progress', 1560.30),
	(4, 'rejected', 0.00)
;

insert into orders_book(id_order, id_book, price, quantity)
values
	(1, 1, 1250.00, 1),
	(1, 3, 1290.50, 2),
	(2, 2, 980.00, 1),
	(2, 4, 450.00, 1),
	(2, 5, 445.00, 1),
	(3, 1, 1200.00, 3),
	(4, 2, 950.00, 2),
	(4, 3, 1250.00, 1),
	(5, 4, 440.00, 1),
	(5, 5, 430.00, 2)
;