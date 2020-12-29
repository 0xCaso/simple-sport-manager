CREATE TABLE Associazione (
	codice 		varchar(20),
	nome 		varchar(80),
	sito		varchar(150),
	email		varchar(80),
	password 	varchar(50),
	PRIMARY KEY(codass)
);

CREATE TABLE Tesserato (
	cf				char(16),	/* Fixed */
	nome			varchar(80),
	cognome			varchar(80),
	data_nascita	date,
	email			varchar(80),
	password		varchar(50),
	telefono		varchar(12), /* con 12 caratteri prendiamo quasi la totalità dei numeri */
	arbitro			bool,
	PRIMARY KEY(cf)
);

CREATE TABLE Citta (
	cap				char(5),
	nome			varchar(100),
	provincia		char(2),
	PRIMARY KEY (cap)
);

CREATE TABLE Sede (
	codass			varchar(20),
	codice			int,
	via				varchar(150),
	cap				char(5),
	nome			varchar(150),
	telefono		varchar(12),
	PRIMARY KEY (codass, codice),
	FOREIGN KEY (codass) 	REFERENCES Associazione(codice),
	FOREIGN KEY (cap)		REFERENCES Citta(cap)
);

CREATE TABLE Fornitore (
	piva				char(11),
	ragione_soc			varchar(150),
	email				varchar(80),
	telefono			varchar(12),
	PRIMARY KEY (piva)
);

CREATE TABLE Campo (
	codass			varchar(20),
	id				int,
	sede			int,
	tipologia		int,
	attrezzatura	bool,
	PRIMARY KEY (codass, id, sede),
	FOREIGN KEY (codass)	REFERENCES Sede(codass),
	FOREIGN KEY (sede)		REFERENCES Sede(codice)
);

CREATE TABLE tipologia_campo (
	codass			varchar(20),
	id				int,
	sport			varchar(50),
	terreno			varchar(50),
	larghezza		int,
	lunghezza		int,
	PRIMARY KEY (codass, id, sede),
	FOREIGN KEY (codass)	REFERENCES Sede(codass),
	FOREIGN KEY (sede)		REFERENCES Sede(codice)
);

CREATE TABLE Dipendente (
	codass			varchar(20),
	cf				char(16),
	nome			varchar(80),
	cognome			varchar(80),
	data_nascita	date,
	email			varchar(80),
	password		varchar(50),
	telefono		varchar(12),
	grado			varchar(10) /* decidere se int o varchar */
	PRIMARY KEY (codass, cf),
	FOREIGN KEY (codass)	REFERENCES Associazione(codice)
);

CREATE TABLE Pagamento (
	codass			varchar(20),	
	importo			money, /* (> 0) => entrata (< 0) => uscita */
	descrizione		varchar(255),
	data			datetime,
	id_dipendente	char(16),
	id_soggetto		varchar(16),
	tipo_operazione int,
	PRIMARY KEY (codass, data, id_dipendente),
	FOREIGN KEY (codass) REFERENCES Dipendente(codass),
	FOREIGN KEY (id_dipendente) REFERENCES Dipendente(cf),
	FOREIGN KEY (tipo_operazione) REFERENCES tipo_operazione(codice)
);

CREATE TABLE tipo_operazione (
	codice			int,
	descrizione		varchar(255),
	PRIMARY KEY (codice)
);

/*
	1 - compenso arbitri
	2 - pagamento fornitore
	3 - pagamento stipendio
	4 - entrata affitto campo
*/













