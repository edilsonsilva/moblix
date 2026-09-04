CREATE TABLE usuarios (
id INT AUTO_INCREMENT PRIMARY KEY,
nome VARCHAR(100) NOT NULL,
email VARCHAR(100) UNIQUE NOT NULL,
senha_hash VARCHAR(255) NOT NULL,
perfil ENUM('Administrador', 'Coordenador', 'Assistente') DEFAULT 'Assistente',
ativo BOOLEAN DEFAULT TRUE,
criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE cursos (
id INT AUTO_INCREMENT PRIMARY KEY,
nome VARCHAR(100) NOT NULL,
sigla VARCHAR(10) NOT NULL,
criado_por INT,
criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
FOREIGN KEY (criado_por) REFERENCES usuarios(id)
);

CREATE TABLE locais (
id INT AUTO_INCREMENT PRIMARY KEY,
nome VARCHAR(100) NOT NULL,
descricao VARCHAR(255),
criado_por INT,
criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
FOREIGN KEY (criado_por) REFERENCES usuarios(id)
);

CREATE TABLE categorias (
id INT AUTO_INCREMENT PRIMARY KEY,
nome VARCHAR(50) NOT NULL,
descricao VARCHAR(255)
);

CREATE TABLE patrimonios (
id INT AUTO_INCREMENT PRIMARY KEY,
numero_tombamento VARCHAR(50) UNIQUE NOT NULL,
nome VARCHAR(150) NOT NULL,
descricao TEXT,
curso_id INT,
local_id INT,
categoria_id INT,
status ENUM('Disponível', 'Emprestado', 'Em Manutenção', 'Baixado/Inativo') DEFAULT 'Disponível',
valor_aquisicao DECIMAL(10,2),
data_aquisicao DATE,
criado_por INT NOT NULL,
atualizado_por INT,
criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
FOREIGN KEY (curso_id) REFERENCES cursos(id) ON DELETE SET NULL,
FOREIGN KEY (local_id) REFERENCES locais(id) ON DELETE SET NULL,
FOREIGN KEY (categoria_id) REFERENCES categorias(id) ON DELETE SET NULL,
FOREIGN KEY (criado_por) REFERENCES usuarios(id),
FOREIGN KEY (atualizado_por) REFERENCES usuarios(id)
);

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
CREATE TABLE baixas_patrimoniais (
id INT AUTO_INCREMENT PRIMARY KEY,
patrimonio_id INT UNIQUE NOT NULL, -- UNIQUE garante que um bem só pode ser baixado uma vez
usuario_registro_id INT NOT NULL,  -- Quem autorizou/registrou a baixa no sistema
tipo_baixa ENUM('Descarte', 'Venda', 'Doação', 'Furto/Roubo', 'Extravio') NOT NULL,
motivo TEXT NOT NULL,
valor_recuperado DECIMAL(10,2) DEFAULT 0.00, -- Registra o valor caso o item tenha sido vendido
documento_comprobatorio VARCHAR(100), -- Ex: Número do B.O., Recibo de Venda, Termo de Descarte
data_baixa DATETIME DEFAULT CURRENT_TIMESTAMP,

FOREIGN KEY (patrimonio_id) REFERENCES patrimonios(id) ON DELETE RESTRICT,
FOREIGN KEY (usuario_registro_id) REFERENCES usuarios(id)
);