CREATE TABLE Associazione (
	codice 		varchar(20),
	ragsoc 		varchar(80) NOT NULL,
	sito		varchar(150) NOT NULL,
	email		varchar(80) NOT NULL,
	password 	varchar(50) NOT NULL,
	PRIMARY KEY(codice)
);

CREATE TABLE Tesserato (
	cf				char(16),	/* Fixed */
	nome			varchar(80) NOT NULL,
	cognome			varchar(80) NOT NULL,
	data_nascita	date NOT NULL,
	email			varchar(80) NOT NULL,
	password		varchar(50) NOT NULL,
	telefono		varchar(12), /* con 12 caratteri prendiamo quasi la totalità dei numeri */
	arbitro			bool DEFAULT false,
	PRIMARY KEY(cf)
);

CREATE TABLE iscrizione (
	codass					varchar(20),
	id_tesserato 			char(16),
	data_iscrizione			date NOT NULL,
	scadenza_iscrizione		date NOT NULL,
	PRIMARY KEY (codass, id_tesserato),
	FOREIGN KEY (codass) REFERENCES Associazione(codice),
	FOREIGN KEY (id_tesserato) REFERENCES Tesserato(cf)
);

CREATE TABLE Citta (
	istat			char(6),
	cap				char(5),
	nome			varchar(100) NOT NULL,
	provincia		char(2) NOT NULL,
	regione			char(3) NOT NULL,
	PRIMARY KEY (istat)
);

CREATE TABLE Sede (
	codass			varchar(20),
	codice			int,
	via				varchar(150) NOT NULL,
	cod_citta		char(6) NOT NULL,
	nome			varchar(150) NOT NULL,
	telefono		varchar(12),
	PRIMARY KEY (codass, codice),
	FOREIGN KEY (codass) 		REFERENCES Associazione(codice),
	FOREIGN KEY (cod_citta)		REFERENCES Citta(istat)
);

CREATE TABLE Fornitore (
	piva				char(11),
	ragione_soc			varchar(150) NOT NULL,
	email				varchar(80) NOT NULL,
	telefono			varchar(12),
	PRIMARY KEY (piva)
);

CREATE TABLE contratti (
	codass				varchar(20),
	cod_fornitore		char(11),
	data_inizio			date NOT NULL,
	data_fine			date, /* NULL fino alla chiusura del contratto => senza un rinnovo */
	PRIMARY KEY (codass, cod_fornitore),
	FOREIGN KEY (codass) REFERENCES Associazione(codice),
	FOREIGN KEY (cod_fornitore) REFERENCES Fornitore(piva)
);

CREATE TABLE Campo (
	codass			varchar(20),
	id				int,
	cod_sede		int,
	tipologia		int NOT NULL,
	attrezzatura	bool DEFAULT false,
	PRIMARY KEY (codass, id, cod_sede),
	FOREIGN KEY (codass, cod_sede)	REFERENCES Sede(codass, codice)
);

CREATE TABLE tipologia_campo (
	codass			varchar(20),
	id				int,
	sport			varchar(50), /* NULL = campo generico */
	terreno			varchar(50) NOT NULL,
	larghezza		int NOT NULL,
	lunghezza		int NOT NULL,
	PRIMARY KEY (codass, id),
	FOREIGN KEY (codass)	REFERENCES Associazione(codice)
);

CREATE TABLE Dipendente (
	codass				varchar(20),
	cf					char(16),
	nome				varchar(80) NOT NULL,
	cognome				varchar(80) NOT NULL,
	data_nascita		date NOT NULL,
	email				varchar(80) NOT NULL,
	password			varchar(50) NOT NULL,
	telefono			varchar(12),
	grado				varchar(50) NOT NULL, /* decidere se int o varchar */
	data_assunzione 	date NOT NULL,
	data_fine			date, /* if IS NOT NULL => licenziato/pensione */
	cod_sede			int,
	PRIMARY KEY (codass, cf),
	FOREIGN KEY (codass)			REFERENCES Associazione(codice),
	FOREIGN KEY (codass, cod_sede)	REFERENCES Sede(codass, codice)
);

CREATE TABLE Pagamento (
	codass			varchar(20),	
	importo			money NOT NULL, /* (> 0) => entrata (< 0) => uscita */
	descrizione		varchar(255) NOT NULL,
	data			timestamp,
	id_dipendente	char(16),
	id_soggetto		varchar(16) NOT NULL,
	tipo_operazione int NOT NULL,
	PRIMARY KEY (codass, data, id_dipendente),
	FOREIGN KEY (codass, id_dipendente) 	REFERENCES Dipendente(codass, cf),
	FOREIGN KEY (tipo_operazione) 			REFERENCES tipo_operazione(codice)
);

CREATE TABLE tipo_operazione (
	codice			int,
	descrizione		varchar(255) NOT NULL,
	PRIMARY KEY (codice)
);

/*
	1 - compenso arbitri
	2 - pagamento fornitore
	3 - pagamento stipendio
	4 - entrata affitto campo
	5 - acquisto gadget
*/













