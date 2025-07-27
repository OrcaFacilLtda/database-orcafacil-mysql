CREATE DATABASE IF NOT EXISTS orcafacil;
USE orcafacil;

-- Tabela de endereços (cada endereço será exclusivo para um usuário OU empresa)
CREATE TABLE endereco (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cep VARCHAR(10),
    rua VARCHAR(100),
    numero VARCHAR(10),
    bairro VARCHAR(100),
    cidade VARCHAR(100),
    estado VARCHAR(2)
);

-- Tabela empresas (prestadores)
CREATE TABLE empresa (
    id INT AUTO_INCREMENT PRIMARY KEY,
    razao_social VARCHAR(150) NOT NULL,
    cnpj VARCHAR(18) UNIQUE NOT NULL,
    descricao TEXT,
    endereco_id INT UNIQUE NOT NULL, -- cada empresa tem 1 endereço exclusivo
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (endereco_id) REFERENCES endereco(id) ON DELETE CASCADE
);

-- Tabela usuários
CREATE TABLE usuario (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    senha VARCHAR(255) NOT NULL,
    telefone VARCHAR(15),
    tipo_usuario ENUM('cliente', 'prestador', 'admin') NOT NULL,
    data_nascimento DATE,
    cpf VARCHAR(14),
    status ENUM('pendente', 'aprovado', 'bloqueado') DEFAULT 'pendente',
    endereco_id INT UNIQUE NOT NULL, -- cada usuário tem 1 endereço exclusivo
    FOREIGN KEY (endereco_id) REFERENCES endereco(id) ON DELETE CASCADE
);

-- Prestador vincula usuário a empresa (1 usuário por empresa)
CREATE TABLE prestador (
    id INT PRIMARY KEY, -- corresponde a usuario.id
    empresa_id INT NOT NULL UNIQUE,
    FOREIGN KEY (id) REFERENCES usuario(id) ON DELETE CASCADE,
    FOREIGN KEY (empresa_id) REFERENCES empresa(id) ON DELETE CASCADE
);

-- Serviços solicitados
CREATE TABLE servico (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id INT NOT NULL,
    empresa_id INT NOT NULL,
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
    data_solicitacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_visita_tecnica DATE NULL,
    data_visita_confirmada BOOLEAN DEFAULT FALSE,
    data_inicio_negociada DATE NULL,
    data_fim_negociada DATE NULL,
    valor_mao_obra DECIMAL(10,2) NULL,
    orcamento_finalizado BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (cliente_id) REFERENCES usuario(id) ON DELETE CASCADE,
    FOREIGN KEY (empresa_id) REFERENCES empresa(id) ON DELETE CASCADE
);

-- Negociação da visita técnica
CREATE TABLE negociacao_visita (
    id INT AUTO_INCREMENT PRIMARY KEY,
    servico_id INT NOT NULL,
    proponente ENUM('prestador', 'cliente') NOT NULL,
    data_visita DATE NOT NULL,
    data_envio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    aceita BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (servico_id) REFERENCES servico(id) ON DELETE CASCADE
);

-- Negociação das datas da obra
CREATE TABLE negociacao_datas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    servico_id INT NOT NULL,
    proponente ENUM('prestador', 'cliente') NOT NULL,
    data_inicio DATE NOT NULL,
    data_fim DATE NOT NULL,
    data_envio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    aceita BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (servico_id) REFERENCES servico(id) ON DELETE CASCADE
);

-- Lista de materiais do orçamento enviada pelo prestador
CREATE TABLE lista_materiais (
    id INT AUTO_INCREMENT PRIMARY KEY,
    servico_id INT NOT NULL,
    nome_material VARCHAR(100),
    quantidade INT,
    preco_unitario DECIMAL(10, 2),
    FOREIGN KEY (servico_id) REFERENCES servico(id) ON DELETE CASCADE
);

-- Pedidos de revisão de orçamento solicitados pelo cliente
CREATE TABLE pedido_revisao_orcamento (
    id INT AUTO_INCREMENT PRIMARY KEY,
    servico_id INT NOT NULL,
    cliente_id INT NOT NULL,
    data_pedido TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    descricao TEXT,
    FOREIGN KEY (servico_id) REFERENCES servico(id) ON DELETE CASCADE,
    FOREIGN KEY (cliente_id) REFERENCES usuario(id) ON DELETE CASCADE
);

-- Avaliação final do serviço pelo cliente
CREATE TABLE avaliacao (
    id INT AUTO_INCREMENT PRIMARY KEY,
    servico_id INT NOT NULL,
    estrelas INT CHECK (estrelas BETWEEN 0 AND 5),
    comentario TEXT,
    data_avaliacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (servico_id) REFERENCES servico(id) ON DELETE CASCADE
);
