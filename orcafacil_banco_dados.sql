CREATE DATABASE orcafacil;
USE orcafacil;

-- Tabela base de usuários (clientes, prestadores, admins)
CREATE TABLE usuario (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    senha VARCHAR(255) NOT NULL,
    tipo_usuario ENUM('cliente', 'prestador', 'admin') NOT NULL,
    foto_perfil LONGBLOB,  -- foto armazenada em formato binário
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Cliente: referência para usuário do tipo cliente
CREATE TABLE cliente (
    id_usuario INT PRIMARY KEY,
    FOREIGN KEY (id_usuario) REFERENCES usuario(id)
);

-- Prestador: referência para usuário do tipo prestador, com aprovação e avaliação
CREATE TABLE prestador (
    id_usuario INT PRIMARY KEY,
    aprovado BOOLEAN DEFAULT FALSE,         -- indica se o prestador foi aprovado pelo admin
    descricao TEXT,                         -- descrição do prestador
    nota_media DECIMAL(3,2) DEFAULT 0.0,  -- média das avaliações
    FOREIGN KEY (id_usuario) REFERENCES usuario(id)
);

-- Solicitação de serviço, com controle de etapa do processo
CREATE TABLE solicitacao (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT,                         -- quem solicitou o serviço
    titulo VARCHAR(100),
    descricao TEXT,
    -- Etapas do processo para controle do fluxo:
    -- 'aguardando_confirmacao_servico' = cliente definiu tipo de serviço, aguardando aprovação/agendamento
    -- 'agendada_visita' = prestador marcou visita para avaliar
    -- 'negociando' = fase de negociação de valores entre cliente e prestador
    -- 'em_atendimento' = serviço em execução
    -- 'finalizada' = serviço concluído
    -- 'cancelada' = serviço cancelado
    etapa ENUM(
        'aguardando_confirmacao_servico',
        'agendada_visita',
        'negociando',
        'em_atendimento',
        'finalizada',
        'cancelada'
    ) DEFAULT 'aguardando_confirmacao_servico',
    status ENUM('aberta', 'fechada') DEFAULT 'aberta',  -- status geral da solicitação
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_cliente) REFERENCES cliente(id_usuario)
);

-- Orçamentos: propostas enviadas pelos prestadores para uma solicitação
CREATE TABLE orcamento (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_solicitacao INT,                     -- solicitação associada
    id_prestador INT,                       -- prestador que enviou
    valor DECIMAL(10,2),                    -- valor proposto
    prazo_dias INT,                         -- prazo estimado em dias
    status ENUM('pendente', 'aceito', 'recusado') DEFAULT 'pendente', -- status da proposta
    data_envio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_solicitacao) REFERENCES solicitacao(id),
    FOREIGN KEY (id_prestador) REFERENCES prestador(id_usuario)
);

-- Confirmações para garantir que cliente e prestador concordem em vários pontos do processo
CREATE TABLE confirmacoes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_orcamento INT UNIQUE,                  -- cada orçamento tem sua confirmação associada
    confirmado_cliente_valor BOOLEAN DEFAULT FALSE,    -- cliente aceita o valor
    confirmado_prestador_valor BOOLEAN DEFAULT FALSE,  -- prestador confirma o valor
    confirmado_cliente_visita BOOLEAN DEFAULT FALSE,   -- cliente confirma visita
    confirmado_prestador_visita BOOLEAN DEFAULT FALSE, -- prestador confirma visita
    atendimento_confirmado BOOLEAN DEFAULT FALSE,      -- confirmação de execução do serviço
    pagamento_confirmado BOOLEAN DEFAULT FALSE,        -- confirmação do pagamento por ambos
    FOREIGN KEY (id_orcamento) REFERENCES orcamento(id)
);

-- Avaliações feitas por cliente e prestador ao final do serviço
CREATE TABLE avaliacao (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_orcamento INT,                        -- referência ao orçamento concluído
    id_avaliador INT,                        -- quem avaliou (cliente ou prestador)
    id_avaliado INT,                         -- quem foi avaliado
    nota INT CHECK (nota BETWEEN 1 AND 5), -- nota de 1 a 5
    comentario TEXT,
    data_avaliacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_orcamento) REFERENCES orcamento(id),
    FOREIGN KEY (id_avaliador) REFERENCES usuario(id),
    FOREIGN KEY (id_avaliado) REFERENCES usuario(id)
);

-- Denúncias feitas por usuários
CREATE TABLE denuncia (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_denunciante INT,                      -- quem fez a denúncia
    id_denunciado INT,                       -- contra quem é a denúncia
    tipo VARCHAR(50),                        -- tipo da denúncia (ex: fraude, má conduta, etc.)
    descricao TEXT,
    -- Status da denúncia
    -- 'pendente' = aberta e aguardando resolução
    -- 'resolvida' = denunciada tratada e encerrada
    -- 'arquivada' = denúncia arquivada sem ação
    status ENUM('pendente', 'resolvida', 'arquivada') DEFAULT 'pendente',
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_denunciante) REFERENCES usuario(id),
    FOREIGN KEY (id_denunciado) REFERENCES usuario(id)
);

-- Ações administrativas tomadas contra denúncias
CREATE TABLE acao_admin (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_admin INT,                           -- admin que tomou a ação
    id_denuncia INT,                        -- denúncia associada
    acao TEXT,                             -- descrição da ação (ex: suspensão, advertência, etc.)
    data_acao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_admin) REFERENCES usuario(id),
    FOREIGN KEY (id_denuncia) REFERENCES denuncia(id)
);
