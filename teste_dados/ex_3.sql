USE bw;

CREATE TABLE dbo.dbw_asset__ex2__registros__produtos
/*
	Objeto dimensão de registro de produtos:
		Contém informações cadastrais dos produtos.
*/
(
	 produto_id				INT					NOT NULL
	,produto_nome			VARCHAR(150)		NOT NULL
	,produto_categoria		VARCHAR(100)		NOT NULL
	,produto_preco_unitario	FLOAT				NOT NULL
	,produto_estoque		FLOAT				NOT NULL
	,insertion_date			DATETIME			DEFAULT	GETDATE()
	,update_date			DATETIME			DEFAULT	GETDATE()
	,df_run_id				UNIQUEIDENTIFIER	NOT NULL

	,CONSTRAINT pk__dbw_asset__ex2__registros__produtos PRIMARY KEY (produto_id)
);

GO

CREATE TABLE dbo.dbw_asset__ex2__registros__clientes
/*
	Objeto dimensão de registro de clientes:
		Contém informações cadastrais dos clientes.
*/
(
	 cliente_id			INT					NOT NULL
	,cliente_nome		VARCHAR(150)		NOT NULL
	,cliente_email		VARCHAR(200)		NOT NULL
	,cliente_telefone	VARCHAR(20)			NOT NULL
	,insertion_date		DATETIME			DEFAULT	GETDATE()
	,update_date		DATETIME			DEFAULT	GETDATE()
	,df_run_id			UNIQUEIDENTIFIER	NOT NULL

	,CONSTRAINT pk__dbw_asset__ex2__registros__clientes PRIMARY KEY (cliente_id)
)

GO

CREATE TABLE dbo.dbw_asset__ex2__registros__lojas
/*
	Objeto dimensão de registro de lojas:
		Contém informações cadastrais das lojas.
*/
(
	 loja_id					SMALLINT			NOT NULL
	,loja_nome					VARCHAR(150)		NOT NULL
	,loja_gerente				VARCHAR(150)		NOT NULL
	,localizacao__pais			VARCHAR(150)		NOT NULL
	,localizacao__estado		VARCHAR(150)		NOT NULL
	,localizacao__cidade		VARCHAR(150)		NOT NULL
	,localizacao__rua			VARCHAR(150)		NOT NULL
	,localizacao__numero		INT					NOT NULL
	,localizacao__complemento	VARCHAR(300)
	,insertion_date				DATETIME			DEFAULT	GETDATE()
	,update_date				DATETIME			DEFAULT	GETDATE()
	,df_run_id					UNIQUEIDENTIFIER	NOT NULL

	,CONSTRAINT pk__dbw_asset__ex2__registros__lojas PRIMARY KEY(loja_id)
);

GO

CREATE TABLE dbo.dbw_asset__ex2__registros__funcionarios
/*
	Objeto dimensão de registro de funcionarios:
		Contém informações cadastrais dos funcionarios.
		Levando em consideração que o desejável é um modelo star schema
		a o par funcionário/loja foi dissociado, de tal forma que haverá um objeto dedicado para registros de lojas e
		teste para funcionários. Idealmente, eu preferiria fazer um modelo no qual haveria um objeto dimansão de registros
		cadastrais de lojas e no modelo de funionários a informação da loja fosse incuída fazendo-se refer6encia chave-estrangeira, porém
		o modelo deixaria de ser star-schema e passaria a ser snowflake, visto que o objeto de de registros de lojas serviria neste modelo como um sub-dimensão
		de funcionários, o que faria sentido fisicamente, pois se uma venda foi realizada por um profissional X, esta venda esteve necessariamente
		associada à loja Y i.e. pode-se considerar a entidade loja como um atributo da entidade funcionário.

		A dissociação do par funcionário/loja permite entretanto garantir um modelo star schema, como proposto no enunciado. Neste modelo, portento,
		a loja não é um atributo do funcionário, logo, a venda por meio de um funcionário X não implica necessariamente que tenha ocorrido numa loja Y.
*/
(
	 funcionario_id		SMALLINT			NOT NULL
	,funcionario_nome	VARCHAR(150)		NOT NULL
	,funcionario_cargo	VARCHAR(50)			NOT NULL
	,insertion_date		DATETIME			DEFAULT	GETDATE()
	,update_date		DATETIME			DEFAULT	GETDATE()
	,df_run_id			UNIQUEIDENTIFIER	NOT NULL

	,CONSTRAINT	pk__dbw_asset__ex2__registros__funcionarios	PRIMARY KEY (funcionario_id)
);

GO

CREATE TABLE dbo.fbw_asset__ex2__registros__vendas
/*
	Objeto dimensão de registro de produtos:
		Contém informações cadastrais dos produtos.
*/
(
	 venda_id		INT					NOT NULL
	,produto_id		INT					NOT NULL
	,cliente_id		INT					NOT NULL
	,funcionario_id	SMALLINT			NOT NULL
	,loja_id		SMALLINT			NOT NULL
	,data_venda		DATE				NOT NULL
	,quantidade		FLOAT				NOT NULL
	,valor_total	FLOAT				NOT NULL
	,insertion_date	DATETIME			DEFAULT	GETDATE()
	,update_date	DATETIME			DEFAULT	GETDATE()
	,df_run_id		UNIQUEIDENTIFIER	NOT NULL

	,CONSTRAINT fbw_asset__ex2__registros__vendas__produto		FOREIGN KEY (produto_id)		REFERENCES dbo.dbw_asset__ex2__registros__produtos		(produto_id)
	,CONSTRAINT fbw_asset__ex2__registros__vendas__clientes		FOREIGN KEY (cliente_id)		REFERENCES dbo.dbw_asset__ex2__registros__clientes		(cliente_id)
	,CONSTRAINT fbw_asset__ex2__registros__vendas__funcionarios	FOREIGN KEY (funcionario_id)	REFERENCES dbo.dbw_asset__ex2__registros__funcionarios	(funcionario_id)
	,CONSTRAINT fbw_asset__ex2__registros__vendas__lojas		FOREIGN KEY (loja_id)			REFERENCES dbo.dbw_asset__ex2__registros__lojas			(loja_id)
);
