-- Додавання адміністратора
INSERT INTO admins (id, username, password_hash) 
VALUES (gen_random_uuid(), 'admin_1', 'secured_hash_value');

-- Додавання комп'ютерів
INSERT INTO computers (id, comp_number, type, status) 
VALUES (gen_random_uuid(), 1, 'Common', 'Available'),
       (gen_random_uuid(), 10, 'VIP', 'Available');

-- Додавання тарифів
INSERT INTO tariffs (id, name, price_per_hour, is_night) 
VALUES (gen_random_uuid(), 'Day Standard', 50.00, FALSE),
       (gen_random_uuid(), 'VIP Night', 100.00, TRUE);

-- Додавання клієнта
INSERT INTO clients (id, nickname, email, balance, discount_percent, visit_count, registration_date)
VALUES (gen_random_uuid(), 'gamer123', 'gamer123@example.com', 1000.00, 10, 5, '2023-01-01'),
       (gen_random_uuid(), 'pro_player', 'pro_player@example.com', 1500.00, 15, 8, '2023-01-02');

-- Додавання сесії
INSERT INTO sessions (id, client_id, computer_id, tariff_id, start_time, end_time, total_price, payment_method)
VALUES (gen_random_uuid(), (SELECT id FROM clients WHERE nickname = 'gamer123'), 
       (SELECT id FROM computers WHERE comp_number = 1), 
       (SELECT id FROM tariffs WHERE name = 'Day Standard'), 
       '2023-10-01 14:00:00', '2023-10-01 16:00:00', 100.00, 'Card');

--- Додвання оплати за послуги
INSERT INTO payments (id, client_id, session_id, amount, payment_date, payment_method)
VALUES (gen_random_uuid(), (SELECT id FROM clients WHERE nickname = 'gamer123'), 
       (SELECT id FROM sessions WHERE client_id = (SELECT id FROM clients WHERE nickname = 'gamer123')), 
       35.00, '2023-10-01 15:00:00', 'Card');

--- Додавання послуг
INSERT INTO services (id, name, price)
VALUES (gen_random_uuid(), 'Coffee', 20.00),
       (gen_random_uuid(), 'Hot Chocolate', 15.00);

--- Додавання session_services
INSERT INTO session_services (id, session_id, service_id, quantity)
VALUES (gen_random_uuid(), 
       (SELECT id FROM sessions WHERE client_id = (SELECT id FROM clients WHERE nickname = 'gamer123')), 
       (SELECT id FROM services WHERE name = 'Coffee'), 2);