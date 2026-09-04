-- =====================================================================
-- SCRIPT DE BANCO DE DADOS - SISTEMA DE GESTÃO DE PATRIMÔNIO ESCOLAR
-- Versão 2: suporte multi-tenant (várias instituições) e múltiplos
-- níveis de ensino (Fundamental, Médio, Técnico, Superior)
-- =====================================================================
CREATE DATABASE techdesign_moblix;
USE techdesign_moblix;
-- ---------------------------------------------------------------------
-- TABELA: instituicoes
-- Representa cada escola/faculdade que usa o sistema (multi-tenant).
-- ---------------------------------------------------------------------
CREATE TABLE instituicoes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    cnpj VARCHAR(18) UNIQUE,
    tipo ENUM('Pública', 'Privada', 'Filantrópica') DEFAULT 'Pública',
    endereco VARCHAR(255),
    telefone VARCHAR(20),
    email_contato VARCHAR(100),
    ativo BOOLEAN DEFAULT TRUE,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- ---------------------------------------------------------------------
-- TABELA: usuarios
-- Adicionado instituicao_id. É NULLABLE para permitir um perfil
-- "Super Administrador" que gerencia várias instituições ao mesmo tempo.
-- Usuários comuns (Administrador/Coordenador/Assistente de uma escola
-- específica) devem sempre ter instituicao_id preenchido — essa regra
-- deve ser garantida na aplicação (CHECK não é totalmente portável
-- entre versões de MySQL/MariaDB para essa lógica condicional).
-- ---------------------------------------------------------------------
CREATE TABLE usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    instituicao_id INT,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    senha_hash VARCHAR(255) NOT NULL,
    perfil ENUM('Super Administrador', 'Administrador', 'Coordenador', 'Assistente') DEFAULT 'Assistente',
    ativo BOOLEAN DEFAULT TRUE,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (instituicao_id) REFERENCES instituicoes(id) ON DELETE RESTRICT
);

-- ---------------------------------------------------------------------
-- TABELA: turmas
-- Substitui a antiga tabela "cursos". Serve para qualquer nível de
-- ensino: turma do fundamental, série do médio, curso técnico ou
-- curso/período de faculdade.
-- ---------------------------------------------------------------------
CREATE TABLE turmas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    instituicao_id INT NOT NULL,
    nome VARCHAR(100) NOT NULL,          -- Ex: "6º Ano A", "3º Médio B", "Informática - Módulo 2", "Engenharia Civil - 5º Semestre"
    sigla VARCHAR(15),
    nivel_ensino ENUM(
        'Educação Infantil',
        'Fundamental I',
        'Fundamental II',
        'Ensino Médio',
        'Ensino Técnico',
        'Ensino Superior'
    ) NOT NULL,
    turno ENUM('Manhã', 'Tarde', 'Noite', 'Integral'),
    ano_letivo YEAR,
    criado_por INT,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (instituicao_id) REFERENCES instituicoes(id) ON DELETE RESTRICT,
    FOREIGN KEY (criado_por) REFERENCES usuarios(id)
);

-- ---------------------------------------------------------------------
-- TABELA: locais
-- Adicionado instituicao_id: cada instituição cadastra seus próprios
-- locais (salas, laboratórios, almoxarifados etc.).
-- ---------------------------------------------------------------------
CREATE TABLE locais (
    id INT AUTO_INCREMENT PRIMARY KEY,
    instituicao_id INT NOT NULL,
    nome VARCHAR(100) NOT NULL,
    descricao VARCHAR(255),
    criado_por INT,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (instituicao_id) REFERENCES instituicoes(id) ON DELETE RESTRICT,
    FOREIGN KEY (criado_por) REFERENCES usuarios(id)
);

-- ---------------------------------------------------------------------
-- TABELA: categorias
-- Mantida GLOBAL (compartilhada entre todas as instituições), pois
-- categorias como "Informática", "Mobiliário", "Material de Laboratório"
-- tendem a ser as mesmas independentemente da escola. Se preferir
-- categorias exclusivas por instituição no futuro, basta adicionar
-- uma coluna instituicao_id (nullable, com NULL = categoria global).
-- ---------------------------------------------------------------------
CREATE TABLE categorias (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(50) NOT NULL,
    descricao VARCHAR(255)
);

-- ---------------------------------------------------------------------
-- TABELA: patrimonios
-- Adicionado instituicao_id (isolamento do bem por escola).
-- curso_id foi substituído por turma_id.
-- ---------------------------------------------------------------------
CREATE TABLE patrimonios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    instituicao_id INT NOT NULL,
    numero_tombamento VARCHAR(50) NOT NULL,
    nome VARCHAR(150) NOT NULL,
    descricao TEXT,
    turma_id INT,
    local_id INT,
    categoria_id INT,
    status ENUM('Disponível', 'Emprestado', 'Em Manutenção', 'Baixado/Inativo') DEFAULT 'Disponível',
    valor_aquisicao DECIMAL(10,2),
    data_aquisicao DATE,
    criado_por INT NOT NULL,
    atualizado_por INT,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_tombamento_instituicao (instituicao_id, numero_tombamento), -- o número de tombamento é único DENTRO de cada instituição
    FOREIGN KEY (instituicao_id) REFERENCES instituicoes(id) ON DELETE RESTRICT,
    FOREIGN KEY (turma_id) REFERENCES turmas(id) ON DELETE SET NULL,
    FOREIGN KEY (local_id) REFERENCES locais(id) ON DELETE SET NULL,
    FOREIGN KEY (categoria_id) REFERENCES categorias(id) ON DELETE SET NULL,
    FOREIGN KEY (criado_por) REFERENCES usuarios(id),
    FOREIGN KEY (atualizado_por) REFERENCES usuarios(id)
);

-- ---------------------------------------------------------------------
-- TABELA: movimentacoes
-- Sem alterações estruturais — já referencia patrimonio_id, que agora
-- carrega o vínculo correto com a instituição por herança.
-- ---------------------------------------------------------------------
CREATE TABLE movimentacoes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    patrimonio_id INT NOT NULL,
    usuario_registro_id INT NOT NULL, -- O usuário logado no sistema que fez o registro
    tipo_movimentacao ENUM('Empréstimo', 'Devolução', 'Envio Manutenção', 'Retorno Manutenção', 'Transferência de Local', 'Baixa') NOT NULL,
    responsavel_destino VARCHAR(150), -- Nome do aluno, professor ou técnico que está com o bem
    documento_responsavel VARCHAR(50), -- RA do aluno, chapa do professor, etc.
    data_saida DATETIME DEFAULT CURRENT_TIMESTAMP,
    data_prevista_retorno DATETIME,
    data_retorno_efetivo DATETIME,
    observacoes TEXT,
    FOREIGN KEY (patrimonio_id) REFERENCES patrimonios(id) ON DELETE CASCADE,
    FOREIGN KEY (usuario_registro_id) REFERENCES usuarios(id)
);

-- ---------------------------------------------------------------------
-- TABELA: baixas_patrimoniais
-- Sem alterações estruturais.
-- ---------------------------------------------------------------------
CREATE TABLE baixas_patrimoniais (
    id INT AUTO_INCREMENT PRIMARY KEY,
    patrimonio_id INT UNIQUE NOT NULL, -- UNIQUE garante que um bem só pode ser baixado uma vez
    usuario_registro_id INT NOT NULL,  -- Quem autorizou/registrou a baixa no sistema
    tipo_baixa ENUM('Descarte', 'Venda', 'Doação', 'Furto/Roubo', 'Extravio') NOT NULL,
    motivo TEXT NOT NULL,
    valor_recuperado DECIMAL(10,2) DEFAULT 0.00, -- Registra o valor caso o item tenha sido vendido
    documento_comprobatorio VARCHAR(100), -- Ex: Número do B.O., Recibo de Venda, Termo de Descarte
    data_baixa DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (patrimonio_id) REFERENCES patrimonios(id) ON DELETE RESTRICT,
    FOREIGN KEY (usuario_registro_id) REFERENCES usuarios(id)
);

-- ---------------------------------------------------------------------
-- ÍNDICES ADICIONAIS
-- Aceleram consultas filtradas por instituição, que serão o padrão
-- em praticamente toda a aplicação multi-tenant.
-- ---------------------------------------------------------------------
CREATE INDEX idx_usuarios_instituicao ON usuarios(instituicao_id);
CREATE INDEX idx_turmas_instituicao ON turmas(instituicao_id);
CREATE INDEX idx_locais_instituicao ON locais(instituicao_id);
CREATE INDEX idx_patrimonios_instituicao ON patrimonios(instituicao_id);
CREATE INDEX idx_patrimonios_status ON patrimonios(status);
CREATE INDEX idx_movimentacoes_patrimonio ON movimentacoes(patrimonio_id);


-- --------------------------- Inserts -----------------------------------------------------

-- =====================================================================
-- SEED DATA - SISTEMA DE GESTÃO DE PATRIMÔNIO ESCOLAR (multi-tenant)
-- Este script assume que as tabelas estão VAZIAS (AUTO_INCREMENT
-- começando do 1). A ordem de inserção respeita as dependências de
-- chave estrangeira. Os IDs usados nos comentários refletem a ordem
-- de inserção abaixo.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1) INSTITUIÇÕES (uma de cada nível solicitado)
-- id 1 = Fundamental | id 2 = Médio | id 3 = Técnico | id 4 = Faculdade
-- ---------------------------------------------------------------------
INSERT INTO instituicoes (nome, cnpj, tipo, endereco, telefone, email_contato, ativo) VALUES
('Escola Municipal Monteiro Lobato', '11.111.111/0001-11', 'Pública', 'Rua das Flores, 100 - São Paulo/SP', '(11) 3333-1111', 'contato@monteirolobato.edu.br', TRUE),
('Colégio Estadual Rui Barbosa', '22.222.222/0001-22', 'Pública', 'Av. Central, 200 - São Paulo/SP', '(11) 3333-2222', 'contato@ruibarbosa.edu.br', TRUE),
('Instituto Técnico Novas Tecnologias', '33.333.333/0001-33', 'Privada', 'Rua da Inovação, 300 - São Paulo/SP', '(11) 3333-3333', 'contato@int.edu.br', TRUE),
('Faculdade União do Saber', '44.444.444/0001-44', 'Privada', 'Av. do Conhecimento, 400 - São Paulo/SP', '(11) 3333-4444', 'contato@uniuniao.edu.br', TRUE);

-- ---------------------------------------------------------------------
-- 2) USUÁRIOS
-- id 1 = Super Administrador (instituicao_id NULL, enxerga tudo)
-- id 2,3   -> instituição 1 (Fundamental)
-- id 4,5   -> instituição 2 (Médio)
-- id 6,7   -> instituição 3 (Técnico)
-- id 8,9   -> instituição 4 (Faculdade)
-- ---------------------------------------------------------------------
INSERT INTO usuarios (instituicao_id, nome, email, senha_hash, perfil, ativo) VALUES
(NULL, 'Marcos Vieira', 'marcos.vieira@sistema.edu.br', '$2y$10$hashsuperadmin000000000000000000000000000000000000000', 'Super Administrador', TRUE),
(1, 'Ana Paula Souza', 'ana.souza@monteirolobato.edu.br', '$2y$10$hashexemplo0000000000000000000000000000000000000000001', 'Administrador', TRUE),
(1, 'Carlos Eduardo Lima', 'carlos.lima@monteirolobato.edu.br', '$2y$10$hashexemplo0000000000000000000000000000000000000000002', 'Coordenador', TRUE),
(2, 'Fernanda Ribeiro', 'fernanda.ribeiro@ruibarbosa.edu.br', '$2y$10$hashexemplo0000000000000000000000000000000000000000003', 'Administrador', TRUE),
(2, 'João Pedro Alves', 'joao.alves@ruibarbosa.edu.br', '$2y$10$hashexemplo0000000000000000000000000000000000000000004', 'Assistente', TRUE),
(3, 'Patrícia Gomes', 'patricia.gomes@int.edu.br', '$2y$10$hashexemplo0000000000000000000000000000000000000000005', 'Administrador', TRUE),
(3, 'Rafael Nogueira', 'rafael.nogueira@int.edu.br', '$2y$10$hashexemplo0000000000000000000000000000000000000000006', 'Coordenador', TRUE),
(4, 'Beatriz Cardoso', 'beatriz.cardoso@uniuniao.edu.br', '$2y$10$hashexemplo0000000000000000000000000000000000000000007', 'Administrador', TRUE),
(4, 'Lucas Martins', 'lucas.martins@uniuniao.edu.br', '$2y$10$hashexemplo0000000000000000000000000000000000000000008', 'Assistente', TRUE);

-- ---------------------------------------------------------------------
-- 3) TURMAS
-- id 1,2   -> instituição 1 (Fundamental I / II)
-- id 3,4   -> instituição 2 (Ensino Médio)
-- id 5,6   -> instituição 3 (Ensino Técnico)
-- id 7,8   -> instituição 4 (Ensino Superior)
-- ---------------------------------------------------------------------
INSERT INTO turmas (instituicao_id, nome, sigla, nivel_ensino, turno, ano_letivo, criado_por) VALUES
(1, '5º Ano A', '5ANO-A', 'Fundamental I', 'Manhã', 2026, 2),
(1, '9º Ano B', '9ANO-B', 'Fundamental II', 'Tarde', 2026, 2),
(2, '1º Ano do Ensino Médio A', '1EM-A', 'Ensino Médio', 'Manhã', 2026, 4),
(2, '3º Ano do Ensino Médio B', '3EM-B', 'Ensino Médio', 'Noite', 2026, 4),
(3, 'Técnico em Informática - Módulo 2', 'TINF-M2', 'Ensino Técnico', 'Noite', 2026, 6),
(3, 'Técnico em Administração - Módulo 1', 'TADM-M1', 'Ensino Técnico', 'Tarde', 2026, 6),
(4, 'Engenharia Civil - 5º Semestre', 'ENGCIV-5', 'Ensino Superior', 'Integral', 2026, 8),
(4, 'Administração - 2º Semestre', 'ADM-2', 'Ensino Superior', 'Noite', 2026, 8);

-- ---------------------------------------------------------------------
-- 4) LOCAIS
-- id 1,2   -> instituição 1
-- id 3,4   -> instituição 2
-- id 5,6   -> instituição 3
-- id 7,8   -> instituição 4
-- ---------------------------------------------------------------------
INSERT INTO locais (instituicao_id, nome, descricao, criado_por) VALUES
(1, 'Sala de Aula 5A', 'Sala do 5º Ano A - bloco principal', 2),
(1, 'Almoxarifado Central', 'Depósito de materiais e equipamentos', 2),
(2, 'Laboratório de Ciências', 'Laboratório para aulas práticas de química e física', 4),
(2, 'Sala de Informática', 'Sala com computadores para uso didático', 4),
(3, 'Laboratório de Redes', 'Laboratório com servidores e switches para práticas técnicas', 6),
(3, 'Sala de Administração', 'Sala usada pelo curso técnico em administração', 6),
(4, 'Laboratório de Estruturas', 'Laboratório de engenharia civil', 8),
(4, 'Biblioteca Central', 'Acervo geral da faculdade', 8);

-- ---------------------------------------------------------------------
-- 5) CATEGORIAS (globais, compartilhadas entre instituições)
-- ---------------------------------------------------------------------
INSERT INTO categorias (nome, descricao) VALUES
('Informática', 'Computadores, notebooks, periféricos e equipamentos de rede'),
('Mobiliário', 'Mesas, cadeiras, armários e demais móveis'),
('Material de Laboratório', 'Vidrarias, reagentes e equipamentos de laboratório'),
('Audiovisual', 'Projetores, caixas de som, câmeras e equipamentos de mídia'),
('Material Esportivo', 'Bolas, redes e equipamentos para educação física');

-- ---------------------------------------------------------------------
-- 6) PATRIMÔNIOS
-- Números de tombamento únicos POR instituição (prefixo indica a escola)
-- ---------------------------------------------------------------------
INSERT INTO patrimonios (instituicao_id, numero_tombamento, nome, descricao, turma_id, local_id, categoria_id, status, valor_aquisicao, data_aquisicao, criado_por, atualizado_por) VALUES
(1, 'ML-2026-0001', 'Notebook Dell Vostro', 'Notebook para uso administrativo', NULL, 2, 1, 'Disponível', 3200.00, '2026-02-10', 2, 2),
(1, 'ML-2026-0002', 'Carteira Escolar', 'Conjunto de carteira e cadeira escolar', 1, 1, 2, 'Disponível', 350.00, '2026-01-15', 2, 2),
(2, 'RB-2026-0001', 'Projetor Epson PowerLite', 'Projetor multimídia para salas de aula', 3, 4, 4, 'Emprestado', 2100.00, '2025-11-05', 4, 4),
(2, 'RB-2026-0002', 'Microscópio Óptico', 'Microscópio para aulas de biologia', 3, 3, 3, 'Disponível', 890.00, '2025-08-20', 4, 4),
(3, 'INT-2026-0001', 'Switch Gerenciável 24 Portas', 'Equipamento de rede para laboratório técnico', 5, 5, 1, 'Disponível', 1450.00, '2026-03-01', 6, 6),
(3, 'INT-2026-0002', 'Computador Desktop i5', 'Estação de trabalho para curso técnico de informática', 5, 5, 1, 'Em Manutenção', 2800.00, '2025-06-12', 6, 7),
(4, 'UNI-2026-0001', 'Estação Total Topográfica', 'Equipamento de medição para engenharia civil', 7, 7, 3, 'Disponível', 15000.00, '2025-09-18', 8, 8),
(4, 'UNI-2026-0002', 'Notebook Lenovo ThinkPad', 'Notebook cedido para uso em pesquisa', 8, 8, 1, 'Baixado/Inativo', 4200.00, '2023-04-22', 8, 9);

-- ---------------------------------------------------------------------
-- 7) MOVIMENTAÇÕES
-- ---------------------------------------------------------------------
INSERT INTO movimentacoes (patrimonio_id, usuario_registro_id, tipo_movimentacao, responsavel_destino, documento_responsavel, data_saida, data_prevista_retorno, data_retorno_efetivo, observacoes) VALUES
(3, 4, 'Empréstimo', 'Prof. Ricardo Andrade', 'CHAPA-4521', '2026-08-10 08:00:00', '2026-08-10 18:00:00', NULL, 'Uso para aula de projeção na sala 12'),
(6, 6, 'Envio Manutenção', 'Assistência Técnica InfoFix', 'OS-778899', '2026-08-15 09:30:00', '2026-08-25 00:00:00', NULL, 'Computador apresentou falha na fonte de alimentação'),
(8, 9, 'Baixa', NULL, NULL, '2026-01-05 10:00:00', NULL, '2026-01-05 10:00:00', 'Equipamento obsoleto, substituído por modelo mais recente');

-- ---------------------------------------------------------------------
-- 8) BAIXAS PATRIMONIAIS
-- Referente ao notebook (patrimonio_id = 8) que foi baixado
-- ---------------------------------------------------------------------
INSERT INTO baixas_patrimoniais (patrimonio_id, usuario_registro_id, tipo_baixa, motivo, valor_recuperado, documento_comprobatorio, data_baixa) VALUES
(8, 9, 'Doação', 'Equipamento obsoleto, doado para ONG parceira após substituição', 0.00, 'TERMO-DOACAO-0012', '2026-01-05 10:15:00');