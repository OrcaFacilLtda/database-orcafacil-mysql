CREATE DATABASE orcafacil;
USE orcafacil;

-- Usuários (clientes, prestadores e admins)
CREATE TABLE usuario (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    senha VARCHAR(255) NOT NULL,
    tipo_usuario ENUM('cliente', 'prestador', 'admin') NOT NULL,
    aprovado BOOLEAN DEFAULT FALSE, -- só para cliente e prestador, admins ignoram
    foto_perfil LONGBLOB,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Cliente: referência para usuário do tipo cliente
CREATE TABLE cliente (
    id_usuario INT PRIMARY KEY,
    FOREIGN KEY (id_usuario) REFERENCES usuario(id)
);

-- Prestador: referência para usuário do tipo prestador, com descrição e avaliação
CREATE TABLE prestador (
    id_usuario INT PRIMARY KEY,
    descricao TEXT,
    nota_media DECIMAL(3,2) DEFAULT 0.0,
    FOREIGN KEY (id_usuario) REFERENCES usuario(id)
);

-- Solicitação de serviço, com controle de etapa do processo
CREATE TABLE solicitacao (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT,
    titulo VARCHAR(100),
    descricao TEXT,
    etapa ENUM(
        'aguardando_confirmacao_servico',
        'agendada_visita',
        'negociando',
        'em_atendimento',
        'finalizada',
        'cancelada'
    ) DEFAULT 'aguardando_confirmacao_servico',
    status ENUM('aberta', 'fechada') DEFAULT 'aberta',
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_cliente) REFERENCES cliente(id_usuario)
);

-- Orçamentos: propostas enviadas pelos prestadores para uma solicitação
CREATE TABLE orcamento (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_solicitacao INT,
    id_prestador INT,
    valor DECIMAL(10,2),
    prazo_dias INT,
    status ENUM('pendente', 'aceito', 'recusado') DEFAULT 'pendente',
    data_envio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_solicitacao) REFERENCES solicitacao(id),
    FOREIGN KEY (id_prestador) REFERENCES prestador(id_usuario)
);

-- Confirmações para garantir que cliente e prestador concordem em vários pontos do processo
CREATE TABLE confirmacoes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_orcamento INT UNIQUE,
    confirmado_cliente_valor BOOLEAN DEFAULT FALSE,
    confirmado_prestador_valor BOOLEAN DEFAULT FALSE,
    confirmado_cliente_visita BOOLEAN DEFAULT FALSE,
    confirmado_prestador_visita BOOLEAN DEFAULT FALSE,
    atendimento_confirmado BOOLEAN DEFAULT FALSE,
    pagamento_confirmado BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (id_orcamento) REFERENCES orcamento(id)
);

-- Avaliações feitas por cliente e prestador ao final do serviço
CREATE TABLE avaliacao (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_orcamento INT,
    id_avaliador INT,
    id_avaliado INT,
    nota INT CHECK (nota BETWEEN 1 AND 5),
    comentario TEXT,
    data_avaliacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_orcamento) REFERENCES orcamento(id),
    FOREIGN KEY (id_avaliador) REFERENCES usuario(id),
    FOREIGN KEY (id_avaliado) REFERENCES usuario(id)
);

-- Denúncias feitas por usuários
CREATE TABLE denuncia (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_denunciante INT,
    id_denunciado INT,
    tipo VARCHAR(50),
    descricao TEXT,
    status ENUM('pendente', 'resolvida', 'arquivada') DEFAULT 'pendente',
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_denunciante) REFERENCES usuario(id),
    FOREIGN KEY (id_denunciado) REFERENCES usuario(id)
);

-- Ações administrativas tomadas contra denúncias
CREATE TABLE acao_admin (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_admin INT,
    id_denuncia INT,
    acao TEXT,
    data_acao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_admin) REFERENCES usuario(id),
    FOREIGN KEY (id_denuncia) REFERENCES denuncia(id)
);
