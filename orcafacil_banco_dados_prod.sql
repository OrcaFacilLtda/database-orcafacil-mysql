CREATE DATABASE IF NOT EXISTS orcafacil;
USE orcafacil;

-- Endereços (exclusivo para usuário ou empresa)
CREATE TABLE address (
    id INT AUTO_INCREMENT PRIMARY KEY,
    zip_code VARCHAR(10),
    street VARCHAR(100),
    number VARCHAR(10),
    neighborhood VARCHAR(100),
    city VARCHAR(100),
    state VARCHAR(2),
    complement VARCHAR(30)
);

-- Empresas (prestadores de serviço)
CREATE TABLE company (
    id INT AUTO_INCREMENT PRIMARY KEY,
    legal_name VARCHAR(150) NOT NULL,
    cnpj VARCHAR(14) UNIQUE NOT NULL,
    address_id INT UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (address_id) REFERENCES address(id) ON DELETE CASCADE
);

-- Usuários do sistema
CREATE TABLE user_account (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    phone VARCHAR(15),
    user_type ENUM('cliente', 'prestador', 'admin') NOT NULL,
    birth_date DATE,
    cpf VARCHAR(11),
    status ENUM('pendente', 'aprovado', 'bloqueado') DEFAULT 'pendente',
    address_id INT UNIQUE NOT NULL,
    FOREIGN KEY (address_id) REFERENCES address(id) ON DELETE CASCADE
);

-- Tabela de categorias de serviço
CREATE TABLE category (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description VARCHAR(200) NOT NULL
);

-- Vínculo entre usuário prestador, empresa e categoria (1 categoria por provider)
CREATE TABLE provider (
    id INT PRIMARY KEY, -- corresponde ao id do user_account
    company_id INT NOT NULL UNIQUE,
    category_id INT NOT NULL,
    FOREIGN KEY (id) REFERENCES user_account(id) ON DELETE CASCADE,
    FOREIGN KEY (company_id) REFERENCES company(id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES category(id) ON DELETE RESTRICT
);

-- Solicitações de serviço
CREATE TABLE service (
    id INT AUTO_INCREMENT PRIMARY KEY,
    client_id INT NOT NULL,
    company_id INT NOT NULL,
    descricao TEXT NOT NULL,
    status ENUM(
        'Solicitação Enviada',
        'Recusado',
        'Negociando Visita',
        'Visita Confirmada',
        'Negociando Datas',
        'Orcamento Em Negociacao',
        'Em Execucao',
        'Concluido'
    ) DEFAULT 'Solicitação Enviada',
    request_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    technical_visit_date DATE NULL,
    visit_confirmed BOOLEAN DEFAULT FALSE,
    negotiated_start_date DATE NULL,
    negotiated_end_date DATE NULL,
    labor_cost DECIMAL(10,2) NULL,
    budget_finalized BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (client_id) REFERENCES user_account(id) ON DELETE CASCADE,
    FOREIGN KEY (company_id) REFERENCES company(id) ON DELETE CASCADE
);

-- Negociação da visita técnica
CREATE TABLE visit_negotiation (
    id INT AUTO_INCREMENT PRIMARY KEY,
    service_id INT NOT NULL,
    proposer ENUM('prestador', 'cliente') NOT NULL,
    visit_date DATE NOT NULL,
    sent_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    accepted BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (service_id) REFERENCES service(id) ON DELETE CASCADE
);

-- Negociação das datas da obra
CREATE TABLE date_negotiation (
    id INT AUTO_INCREMENT PRIMARY KEY,
    service_id INT NOT NULL,
    proposer ENUM('prestador', 'cliente') NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    sent_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    accepted BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (service_id) REFERENCES service(id) ON DELETE CASCADE
);

-- Lista de materiais enviada pelo prestador
CREATE TABLE material_list (
    id INT AUTO_INCREMENT PRIMARY KEY,
    service_id INT NOT NULL,
    nome_material VARCHAR(100),
    quantity INT,
    unit_price DECIMAL(10, 2),
    FOREIGN KEY (service_id) REFERENCES service(id) ON DELETE CASCADE
);

-- Pedidos de revisão de orçamento pelo cliente
CREATE TABLE budget_revision_request (
    id INT AUTO_INCREMENT PRIMARY KEY,
    service_id INT NOT NULL,
    client_id INT NOT NULL,
    request_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    descricao TEXT,
    FOREIGN KEY (service_id) REFERENCES service(id) ON DELETE CASCADE,
    FOREIGN KEY (client_id) REFERENCES user_account(id) ON DELETE CASCADE
);

-- Avaliação final do serviço
CREATE TABLE evaluation (
    id INT AUTO_INCREMENT PRIMARY KEY,
    service_id INT NOT NULL,
    stars INT CHECK (stars BETWEEN 0 AND 5),
    comentario TEXT,
    evaluation_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (service_id) REFERENCES service(id) ON DELETE CASCADE
);
