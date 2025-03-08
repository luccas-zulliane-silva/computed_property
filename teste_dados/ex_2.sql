USE [bw];


GO

CREATE TABLE dbo.dbw_asset__registros__clientes
/*
	Objeto dimensão de registro de clientes:
		Contém informações cadastrais dos clientes.
*/
(
	 cliente_id 				INT					NOT NULL
	,cliente_nome				VARCHAR(300)		NOT NULL
	,cliente_cpf				VARCHAR(30)			NOT NULL
	,cliente_data_nascimento	DATE				NOT NULL
	,cliente_numero_celular		VARCHAR(20)			NOT NULL
	,cliente_numero_fixo		VARCHAR(20)
	,cliente_email				VARCHAR(150)		NOT NULL
	,insertion_date				DATETIME			DEFAULT	GETDATE()
	,update_date				DATETIME			DEFAULT	GETDATE()
	,df_run_id					UNIQUEIDENTIFIER	NOT NULL

	,CONSTRAINT pk__dbw_asset__clientes PRIMARY KEY (cliente_id)
);

GO

CREATE TABLE dbo.dbw_asset__registros__moedas
/*
	Objeto dimensão de registro de moedas:
		Contém informações cadastrais de moedas dos países.
*/
(
	 moeda_id		TINYINT				NOT NULL
	,moeda_codigo	CHAR(3)				NOT NULL			-- e.g. EUR
	,moeda_numero	CHAR(3)				NOT NULL			-- e.g. 978
	,insertion_date	DATETIME			DEFAULT	GETDATE()
	,update_date	DATETIME			DEFAULT	GETDATE()
	,df_run_id		UNIQUEIDENTIFIER	NOT NULL

	,CONSTRAINT pk__dbw_asset__registros__moedas PRIMARY KEY (moeda_id)
);

GO

CREATE TABLE dbo.dbw_asset__registros__ativos
/*
	Objeto dimensão de registro de instrumentos financeiros:
		Contém informações cadastrais de instrumentos financeiros.
		Este objeto pode conter registrros gerais de instrumentos de renda-fixa (o campo 'ativo_codigo')
		neste caso pode sre interpretado como o código CETIP do instrumento, ativos de renda variáveis e fundos de investimento.
		Outras informações seriam necessárias e.g. data de início de pagamento de juros/amortização, emissores, devedores,
		rating, número de emissão, data de emissão, número de série, entre outros, porém este objeto é apenas um esboço
		para registros gerais, não específicos para cada classe de ativo.

*/
(
	 ativo_id				INT					NOT NULL
	,ativo_codigo			VARCHAR(30)			NOT NULL			--e.g. código cetip (CVRDA6), CNPJ de fundo de investimento, ticker de ação, FII listado, ETF etc
	,ativo_data_vencimento	DATE
	,moeda_id				TINYINT				NOT NULL
	,insertion_date			DATETIME			DEFAULT	GETDATE()
	,update_date			DATETIME			DEFAULT	GETDATE()
	,df_run_id				UNIQUEIDENTIFIER	NOT NULL

	,CONSTRAINT pk__dbw_asset__registros__ativos			PRIMARY KEY (ativo_id)
	,CONSTRAINT fk__dbw_asset__registros__ativos__moedas	FOREIGN KEY (moeda_id) REFERENCES dbo.dbw_asset__registros__moedas(moeda_id)
);

GO

CREATE TABLE dbo.fbw_asset__precificacao__ativos
/*
	Objeto fato de registro de moedas:
		Contém registro diário/intradiário de precificação de instrumentos. Os registros intradiários podem
		ser diferenciados por meio do campo 'insertion_date'.

*/
(
	 data_referencia	DATE				NOT NULL
	,ativo_id			INT					NOT NULL
	,pu					FLOAT				NOT NULL
	,insertion_date		DATETIME			DEFAULT	GETDATE()
	,update_date		DATETIME			DEFAULT	GETDATE()
	,df_run_id			UNIQUEIDENTIFIER	NOT NULL

	,CONSTRAINT fk__dbw_asset__precificacao__ativos__registros__ativos FOREIGN KEY (ativo_id) REFERENCES dbo.dbw_asset__registros__ativos(ativo_id)
);

GO

CREATE TABLE dbo.dbw_asset__registros__custodiantes
/*
	Objeto dimensão de registro de custodiantes:
		Contém registros cadastrais dos custodiantes de portfólios.

*/
(
	 custodiante_id		SMALLINT			NOT NULL
	,custodiante_cnpj	VARCHAR(20)			NOT NULL
	,custodiante_nome	VARCHAR(300)		NOT NULL
	,insertion_date		DATETIME			DEFAULT	GETDATE()
	,update_date		DATETIME			DEFAULT	GETDATE()
	,df_run_id			UNIQUEIDENTIFIER	NOT NULL

	,CONSTRAINT pk__dbw_asset__registros__custodiantes PRIMARY KEY(custodiante_id)
);

GO

CREATE TABLE dbo.dbw_asset__registros__indexadores
/*
	Objeto dimensão de registro de indexadores:
		Contém registros cadastrais de indexadores (benchmarks).

*/
(
	 indexador_id	SMALLINT	NOT NULL
	,indexador_nome	VARCHAR(30)	NOT NULL -- e.g. DI, IPCA, PRE

	,CONSTRAINT pk__dbw_asset__registros__indexadores PRIMARY KEY (indexador_id)
);

GO

CREATE TABLE dbo.dbw_asset__registros__portfolios
/*
	Objeto dimensão de registro de portfolios:
		Contém registros cadastrais dos portfólios dos clientes.
*/
(
	 portfolio_id				INT					NOT NULL
	,portfolio_nome				VARCHAR(150)		NOT NULL			--e.g. RENDA VARIÁVEL
	,portfolio_data_inicio		DATE				NOT NULL
	,portfolio_data_termino		DATE
	,custodiante_id				SMALLINT			NOT NULL
	,taxa_administracao			FLOAT									-- e.g. 0.5% a.a.
	,taxa_performance			FLOAT									-- e.g. 20% do que exceder indexador
	,indexador_id				SMALLINT
	,indexador_multiplicador	FLOAT									-- e.g. 110%DI
	,indexador_taxa_flutuante	FLOAT									-- e.g. IPCA+6%
	,insertion_date				DATETIME			DEFAULT	GETDATE()
	,update_date				DATETIME			DEFAULT	GETDATE()
	,df_run_id					UNIQUEIDENTIFIER	NOT NULL

	,CONSTRAINT pk__dbw_asset__registros__portfolio					PRIMARY KEY (portfolio_id)
	,CONSTRAINT fk__dbw_asset__registros__portfolios__custodiantes	FOREIGN KEY (custodiante_id)			REFERENCES dbo.dbw_asset__registros__custodiantes(custodiante_id)
	,CONSTRAINT fk__dbw_asset__registros__portfolios__indexadores	FOREIGN KEY (indexador_id)				REFERENCES dbo.dbw_asset__registros__indexadores(indexador_id)
);

GO

CREATE TABLE dbo.dbw_asset__registros__portfolios__clientes
/*
	Objeto dimensão de registro do relacionamento entre portfolios e clientes
*/
(
	 portfolio_id	INT					NOT NULL
	,cliente_id		INT					NOT NULL
	,insertion_date	DATETIME			DEFAULT	GETDATE()
	,update_date	DATETIME			DEFAULT	GETDATE()
	,df_run_id		UNIQUEIDENTIFIER	NOT NULL

	,CONSTRAINT pk__dbw_asset__registros__portfolios__clientes__portfolios	FOREIGN KEY (portfolio_id)	REFERENCES dbo.dbw_asset__registros__portfolios(portfolio_id)
	,CONSTRAINT pk__dbw_asset__registros__portfolios__clientes__clientes	FOREIGN KEY (cliente_id)	REFERENCES dbo.dbw_asset__registros__clientes(cliente_id)
)

GO

CREATE TABLE dbo.fbw_asset__portfolios
/*
	Objeto fato de registro de portfolios:
		Contém registros quantitativos de posição dos portfólios em cada instrumento financeiro.
*/
(
	 data_referencia	DATE				NOT NULL
	,portfolio_id		INT					NOT NULL
	,ativo_id			INT					NOT NULL
	,ativo_quantidade	FLOAT				NOT NULL
	,ativo_peso			FLOAT				NOT NULL
	,insertion_date		DATETIME			DEFAULT	GETDATE()
	,update_date		DATETIME			DEFAULT	GETDATE()
	,df_run_id			UNIQUEIDENTIFIER	NOT NULL

	,CONSTRAINT fk__fbw_asset__portfolios__registros__portfolios	FOREIGN KEY (portfolio_id)	REFERENCES dbo.dbw_asset__registros__portfolios(portfolio_id)
	,CONSTRAINT fk__fbw_asset__portfolios__ativos					FOREIGN KEY (ativo_id)		REFERENCES dbo.dbw_asset__registros__ativos(ativo_id)
);

GO

CREATE TABLE dbo.dbw_asset__registros__corretoras
/*
	Objeto dimesão de registro de corretoras:
		Contém registros cadastrais de corretoras. Corretoras são usadas nas transações dos instrumentos.
*/
(
	 corretora_id		SMALLINT			NOT NULL
	,corretora_cnpj		VARCHAR(20)			NOT NULL
	,corretora_nome		VARCHAR(300)		NOT NULL
	,rebate_corretagem	FLOAT									-- e.g. 80%
	,insertion_date		DATETIME			DEFAULT	GETDATE()
	,update_date		DATETIME			DEFAULT	GETDATE()
	,df_run_id			UNIQUEIDENTIFIER	NOT NULL

	,CONSTRAINT pk__dbw_asset__registros__corretoras PRIMARY KEY (corretora_id)
)

GO

CREATE TABLE dbo.fbw_asset__transacoes__portfolios
/*
	Objeto fato de registro de boletas de portfolios
*/
(
	 data_referencia	DATE				NOT NULL			-- data de solicitação de compra/venda
	,portfolio_id		INT					NOT NULL
	,ativo_id			INT					NOT NULL
	,data_registro		DATE				NOT NULL			-- data de 'cotização' da transação
	,data_liquidacao	DATE				NOT NULL			-- data de liquidação financeira
	,quantidade			FLOAT				NOT NULL
	,pu					FLOAT				NOT NULL
	,taxa				FLOAT
	,corretora_id		SMALLINT			NOT NULL
	,insertion_date		DATETIME			DEFAULT	GETDATE()
	,update_date		DATETIME			DEFAULT	GETDATE()
	,df_run_id			UNIQUEIDENTIFIER	NOT NULL

	,CONSTRAINT fk__fbw_asset__transacoes__portfolios__registros__portfolios	FOREIGN KEY (portfolio_id)	REFERENCES dbo.dbw_asset__registros__portfolios(portfolio_id)
	,CONSTRAINT fk__fbw_asset__transacoes__portfolios__registros__ativos		FOREIGN KEY (ativo_id)		REFERENCES dbo.dbw_asset__registros__ativos(ativo_id)
	,CONSTRAINT fk__fbw_asset__transacoes__portfolios__registros__corretoras	FOREIGN KEY (corretora_id)	REFERENCES dbo.dbw_asset__registros__corretoras(corretora_id)
)

GO

CREATE TABLE dbo.dbw_asset__registros__rendimentos
/*
	Objeto dimensão de registro de rendimentos
*/
(
	 rendimento_id		TINYINT				NOT NULL
	,rendimento_nome	VARCHAR(30)			NOT NULL			-- e.g. cupom, amortização, dividendo
	,insertion_date		DATETIME			DEFAULT	GETDATE()
	,update_date		DATETIME			DEFAULT	GETDATE()
	,df_run_id			UNIQUEIDENTIFIER	NOT NULL

	,CONSTRAINT pk__dbw_asset__registros__rendimentos PRIMARY KEY (rendimento_id)
)

GO

CREATE TABLE dbo.fbw_asset__rendimentos__ativos
/*
	Objeto fato de registros quantitativos de rendimentos.
*/
(
	 data_referencia	DATE				NOT NULL
	,ativo_id			INT					NOT NULL
	,pu					FLOAT				NOT NULL
	,rendimento_id		TINYINT				NOT NULL
	,insertion_date		DATETIME			DEFAULT	GETDATE()
	,update_date		DATETIME			DEFAULT	GETDATE()
	,df_run_id			UNIQUEIDENTIFIER	NOT NULL

	,CONSTRAINT fk__fbw_asset__rendimentos__ativos__registros__ativos		FOREIGN KEY (ativo_id)		REFERENCES dbo.dbw_asset__registros__ativos(ativo_id)
	,CONSTRAINT fk__fbw_asset__rendimentos__ativos__registros__rendimentos	FOREIGN KEY (rendimento_id)	REFERENCES dbo.dbw_asset__registros__rendimentos(rendimento_id)
)