CREATE TYPE computer_type_enum AS ENUM ('Common', 'VIP');
CREATE TYPE computer_status_enum AS ENUM ('Available', 'Busy', 'Maintenance');
CREATE TYPE payment_method_enum AS ENUM ('Cash', 'Card', 'Balance');

-- 1. Admins (3НФ - Дані про адміністраторів)
CREATE TABLE admins (
    PRIMARY KEY(id),
    id            UUID,
    username      VARCHAR(64) NOT NULL,
                  CONSTRAINT admins_username_unique UNIQUE (username),
    password_hash VARCHAR(255) NOT NULL
);

-- 2. Clients (3НФ - Дані клієнтів)
CREATE TABLE clients (
    PRIMARY KEY(id),
    id                UUID,
    nickname          VARCHAR(64) NOT NULL,
                      CONSTRAINT clients_nickname_unique UNIQUE (nickname),
    
    email             VARCHAR(255) NOT NULL,
                      CONSTRAINT clients_email_unique UNIQUE (email),
                      CONSTRAINT clients_email_check CHECK (email LIKE '%@%'),

    balance           DECIMAL(10, 2) DEFAULT 0.00,
                      CONSTRAINT clients_balance_positive_check CHECK (balance >= 0),

    discount_percent  INTEGER DEFAULT 0,
                      CONSTRAINT clients_discount_range_check 
                      CHECK (discount_percent >= 0 AND discount_percent <= 100),

    visit_count       INTEGER DEFAULT 0,
                      CONSTRAINT clients_visit_count_positive_check CHECK (visit_count >= 0),

    registration_date DATE DEFAULT CURRENT_DATE
);

-- 3. Computers (3НФ - Стрижнева сутність ресурсів)
CREATE TABLE computers (
    PRIMARY KEY(id),
    id           UUID,
    comp_number  INTEGER NOT NULL,
                 CONSTRAINT computers_number_positive_check CHECK (comp_number > 0),
                 CONSTRAINT computers_number_unique UNIQUE (comp_number),
    type         computer_type_enum NOT NULL,
    status       computer_status_enum NOT NULL DEFAULT 'Available'
);

-- 4. Tariffs (3НФ - Довідник цін)
CREATE TABLE tariffs (
    PRIMARY KEY(id),
    id             UUID,
    name           VARCHAR(64) NOT NULL,
    price_per_hour DECIMAL(10, 2) NOT NULL,
                   CONSTRAINT tariffs_price_positive_check CHECK (price_per_hour > 0),
    is_night       BOOLEAN DEFAULT FALSE
);

-- 5. Sessions (3НФ - Транзакційна таблиця сесій)
CREATE TABLE sessions (
    PRIMARY KEY(id),
    id            UUID,
    client_id     UUID NOT NULL,
                  CONSTRAINT sessions_client_fkey FOREIGN KEY (client_id) 
                  REFERENCES clients(id) ON DELETE CASCADE,
    
    computer_id   UUID NOT NULL,
                  CONSTRAINT sessions_computer_fkey FOREIGN KEY (computer_id) 
                  REFERENCES computers(id) ON DELETE CASCADE,

    tariff_id     UUID NOT NULL,
                  CONSTRAINT sessions_tariff_fkey FOREIGN KEY (tariff_id) 
                  REFERENCES tariffs(id),

    start_time    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    end_time      TIMESTAMP,
    total_cost    DECIMAL(10, 2) DEFAULT 0.00,
                  CONSTRAINT sessions_cost_positive_check CHECK (total_cost >= 0),
    is_active     BOOLEAN DEFAULT TRUE
);

-- 6. Services (3НФ - Додаткові послуги)
CREATE TABLE services (
    PRIMARY KEY(id),
    id    UUID,
    name  VARCHAR(64) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
          CONSTRAINT services_price_positive_check CHECK (price > 0)
);

-- 7. Session_Services (2НФ - Зв'язок Багато до Багатьох)
-- Одна сесія може мати багато послуг, одна послуга може бути в багатьох сесіях
CREATE TABLE session_services (
    PRIMARY KEY(session_id, service_id),
    session_id UUID NOT NULL,
               CONSTRAINT sess_serv_session_fkey FOREIGN KEY (session_id) 
               REFERENCES sessions(id) ON DELETE CASCADE,
    service_id UUID NOT NULL,
               CONSTRAINT sess_serv_service_fkey FOREIGN KEY (service_id) 
               REFERENCES services(id) ON DELETE CASCADE,
    quantity   INTEGER DEFAULT 1,
               CONSTRAINT sess_serv_quantity_check CHECK (quantity > 0)
);

-- 8. Payments (3НФ - Фінансова звітність)
CREATE TABLE payments (
    PRIMARY KEY(id),
    id           UUID,
    client_id    UUID NOT NULL,
                 CONSTRAINT payments_client_fkey FOREIGN KEY (client_id) 
                 REFERENCES clients(id) ON DELETE CASCADE,
    session_id    UUID NOT NULL,
                 CONSTRAINT payments_session_fkey FOREIGN KEY (session_id) 
                 REFERENCES sessions(id) ON DELETE CASCADE,
    amount       DECIMAL(10, 2) NOT NULL,
                 CONSTRAINT payments_amount_positive_check CHECK (amount > 0),
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    method       payment_method_enum NOT NULL
);