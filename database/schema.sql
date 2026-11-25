-- FL hats · schema.sql
-- Sistema online de gestão de reformas de chapéus (Quatá, SP)
-- Projeto Integrador Extensionista II · Jean Henrique Lino dos Santos
--
-- Este arquivo recria o banco do zero a cada execução.

SET NAMES utf8mb4;

DROP DATABASE IF EXISTS flhats;
CREATE DATABASE flhats CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE flhats;

-- ---------------------------------------------------------------
-- cliente
-- Une as entidades CadastroCliente e Cliente do MER (tinham os
-- mesmos dados). O telefone identifica o cliente (RF1, login).
-- LGPD: sem CPF nem e-mail; o endereço existe só para coleta e
-- entrega do chapéu e é opcional.
-- ---------------------------------------------------------------
CREATE TABLE cliente (
  id_cliente    INT AUTO_INCREMENT PRIMARY KEY,
  nome          VARCHAR(150) NOT NULL,
  telefone      VARCHAR(11)  NOT NULL UNIQUE,
  senha_hash    VARCHAR(255) NOT NULL,
  endereco      VARCHAR(255),
  data_cadastro TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CHECK (telefone REGEXP '^[0-9]{10,11}$')
);

-- ---------------------------------------------------------------
-- administrador
-- Único perfil com acesso à área administrativa (RNF1).
-- ---------------------------------------------------------------
CREATE TABLE administrador (
  id_administrador INT AUTO_INCREMENT PRIMARY KEY,
  nome             VARCHAR(150) NOT NULL,
  usuario          VARCHAR(50)  NOT NULL UNIQUE,
  senha_hash       VARCHAR(255) NOT NULL
);

-- ---------------------------------------------------------------
-- servico
-- Catálogo de serviços e valores (RF5, RF6). O serviço não é
-- apagado: fica inativo, para não quebrar pedidos antigos.
-- ---------------------------------------------------------------
CREATE TABLE servico (
  id_servico   INT AUTO_INCREMENT PRIMARY KEY,
  tipo_servico VARCHAR(100)  NOT NULL UNIQUE,
  valor        DECIMAL(10,2) NOT NULL CHECK (valor >= 0),
  ativo        BOOLEAN       NOT NULL DEFAULT TRUE
);

-- ---------------------------------------------------------------
-- pedido
-- Solicitação de reforma feita por um cliente (RF2, RF3, RF4, RF7).
-- Não se apaga um cliente que tenha pedidos (RESTRICT).
-- ---------------------------------------------------------------
CREATE TABLE pedido (
  id_pedido   INT AUTO_INCREMENT PRIMARY KEY,
  id_cliente  INT           NOT NULL,
  data_pedido TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  observacao  VARCHAR(255),
  status      VARCHAR(20)   NOT NULL DEFAULT 'Aguardando',
  valor_total DECIMAL(10,2) NOT NULL DEFAULT 0 CHECK (valor_total >= 0),
  FOREIGN KEY (id_cliente) REFERENCES cliente (id_cliente),
  CHECK (status IN ('Aguardando', 'Em andamento', 'Concluído', 'Cancelado'))
);

-- ---------------------------------------------------------------
-- item_pedido  (associativa N:N entre pedido e servico)
-- Guarda o valor do serviço na data do pedido, para que mudar o
-- preço depois não altere pedidos antigos.
-- Excluir o pedido apaga os itens dele (RF8).
-- ---------------------------------------------------------------
CREATE TABLE item_pedido (
  id_pedido      INT           NOT NULL,
  id_servico     INT           NOT NULL,
  quantidade     INT           NOT NULL CHECK (quantidade > 0),
  valor_unitario DECIMAL(10,2) NOT NULL CHECK (valor_unitario >= 0),
  PRIMARY KEY (id_pedido, id_servico),
  FOREIGN KEY (id_pedido)  REFERENCES pedido (id_pedido) ON DELETE CASCADE,
  FOREIGN KEY (id_servico) REFERENCES servico (id_servico)
);

-- ---------------------------------------------------------------
-- pagamento  (1:1 com pedido: UNIQUE em id_pedido)
-- O cliente vem do pedido, por isso não se repete aqui.
-- Troco só existe em pagamento em dinheiro.
-- ---------------------------------------------------------------
CREATE TABLE pagamento (
  id_pagamento    INT AUTO_INCREMENT PRIMARY KEY,
  id_pedido       INT           NOT NULL UNIQUE,
  forma_pagamento VARCHAR(10)   NOT NULL,
  valor_pago      DECIMAL(10,2) NOT NULL CHECK (valor_pago > 0),
  troco           DECIMAL(10,2) NOT NULL DEFAULT 0 CHECK (troco >= 0),
  data_pagamento  TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id_pedido) REFERENCES pedido (id_pedido) ON DELETE CASCADE,
  CHECK (forma_pagamento IN ('dinheiro', 'cartao')),
  CHECK (forma_pagamento = 'dinheiro' OR troco = 0)
);

-- ---------------------------------------------------------------
-- atualizacao  (registro das ações do administrador, UC07)
-- Se o pedido for excluído, o registro fica com id_pedido nulo.
-- ---------------------------------------------------------------
CREATE TABLE atualizacao (
  id_atualizacao   INT AUTO_INCREMENT PRIMARY KEY,
  id_administrador INT         NOT NULL,
  id_pedido        INT,
  acao             VARCHAR(20) NOT NULL,
  data_hora        TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id_administrador) REFERENCES administrador (id_administrador),
  FOREIGN KEY (id_pedido) REFERENCES pedido (id_pedido) ON DELETE SET NULL,
  CHECK (acao IN ('incluir', 'excluir', 'alterar_status'))
);

-- ---------------------------------------------------------------
-- atualizacao_servico  (associativa N:N entre atualizacao e servico)
-- ---------------------------------------------------------------
CREATE TABLE atualizacao_servico (
  id_atualizacao INT NOT NULL,
  id_servico     INT NOT NULL,
  PRIMARY KEY (id_atualizacao, id_servico),
  FOREIGN KEY (id_atualizacao) REFERENCES atualizacao (id_atualizacao) ON DELETE CASCADE,
  FOREIGN KEY (id_servico)     REFERENCES servico (id_servico) ON DELETE CASCADE
);

-- ---------------------------------------------------------------
-- Dados iniciais: serviços do protótipo (WF04)
-- ---------------------------------------------------------------
INSERT INTO servico (tipo_servico, valor) VALUES
  ('Limpeza',          50.00),
  ('Reforma de aba',   70.00),
  ('Ajuste de copa',   60.00),
  ('Troca de carneira', 80.00);