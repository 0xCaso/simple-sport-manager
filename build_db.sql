CREATE TABLE Associazione (
	codass 		varchar(20),
	nome 		varchar(80),
	sito		varchar(150),
	email		varchar(80),
	password 	varchar(50),
	PRIMARY KEY(codass)
);

CREATE TABLE Tesserato (
	cf				char(16),	/* Fixed */
	codass			varchar(20),
	nome			varchar(80),
	cognome			varchar(80),
	data_nascita	date,
	email			varchar(80),
	password		varchar(50),
	telefono		varchar(12), /* con 12 caratteri prendiamo quasi la totalità dei numeri */
	arbitro			bool,
	PRIMARY KEY(cf, codass),
	FOREIGN KEY (codass) REFERENCES Associazione(codass)
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
	/*PRIMARY KEY (codass, cap, via),*/
	PRIMARY KEY (codass, codice),
	FOREIGN KEY (codass) 	REFERENCES Associazione(codass),
	FOREIGN KEY (cap)		REFERENCES Citta(cap)
);

CREATE TABLE Fornitore (
	piva			char(11),
	nome			varchar(150),
	email			varchar(80),
	telefono		varchar(12),
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














