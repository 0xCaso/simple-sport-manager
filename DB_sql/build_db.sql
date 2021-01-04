ALTER TABLE associazione 		DISABLE TRIGGER ALL;
ALTER TABLE campo 				DISABLE TRIGGER ALL;
ALTER TABLE citta				DISABLE TRIGGER ALL;
ALTER TABLE contratti 			DISABLE TRIGGER ALL;
ALTER TABLE dipendente			DISABLE TRIGGER ALL;
ALTER TABLE esborsi				DISABLE TRIGGER ALL;
ALTER TABLE fatture		 		DISABLE TRIGGER ALL;
ALTER TABLE fornitore			DISABLE TRIGGER ALL;
ALTER TABLE grado_dipendenti	DISABLE TRIGGER ALL;
ALTER TABLE pagamento 			DISABLE TRIGGER ALL;
ALTER TABLE prenotazioni		DISABLE TRIGGER ALL;
ALTER TABLE sede				DISABLE TRIGGER ALL;
ALTER TABLE stipendi 			DISABLE TRIGGER ALL;
ALTER TABLE tesserino			DISABLE TRIGGER ALL;
ALTER TABLE tipologia_campo		DISABLE TRIGGER ALL;

/*drop table if exists associazione;
drop table if exists campo;
drop table if exists citta;
drop table if exists contratti;
drop table if exists dipendente;
drop table if exists esborsi;
drop table if exists fatture;
drop table if exists fornitore;
drop table if exists grado_dipendenti;
drop table if exists pagamento;
drop table if exists prenotazioni;
drop table if exists sede;
drop table if exists stipendi;
drop table if exists tesserino;
drop table if exists tipologia_campo;*/

CREATE TYPE sessi 		AS ENUM ('M', 'F');
CREATE TYPE operazioni 	AS ENUM ('F', 'S', 'E');


CREATE TABLE Associazione (
	codice 		varchar(20),
	ragsoc 		varchar(80) NOT NULL,
	sito		varchar(150) NOT NULL,
	email		varchar(80) NOT NULL check (email like '%_@__%.__%'),
	password 	varchar(50) NOT NULL,
	PRIMARY KEY(codice)
);

CREATE TABLE Tesserino (
	codass					varchar(20),
	cf						char(16),
	nome					varchar(80) NOT NULL,
	cognome					varchar(80) NOT NULL,
	data_nascita			date NOT NULL,
	email					varchar(80) NOT NULL check (email like '%_@__%.__%'),
	password				varchar(50) NOT NULL,
	telefono				varchar(12), /* con 12 caratteri prendiamo quasi la totalità dei numeri */
	arbitro					bool DEFAULT false,
	data_iscrizione			date NOT NULL,
	scadenza_iscrizione		date NOT NULL,
	sesso 					sessi NOT NULL,
	PRIMARY KEY(codass, cf),
	FOREIGN KEY (codass) REFERENCES Associazione(codice)
);

CREATE TABLE Citta (
	istat			char(6),
	cap				char(5) NOT NULL,
	nome			varchar(100) NOT NULL,
	provincia		char(2) NOT NULL,
	regione			char(3) NOT NULL,
	PRIMARY KEY (istat)
);

CREATE TABLE Sede (
	codass			varchar(20),
	codice			int,
	via				varchar(150) NOT NULL,
	cod_civico 		int NOT NULL,
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
	email				varchar(80) NOT NULL check (email like '%_@__%.__%'),
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

CREATE TABLE tipologia_campo (
	codass			varchar(20),
	id				int,
	sport			varchar(50), /* NULL = campo generico */
	terreno			varchar(50) NOT NULL,
	larghezza		smallint NOT NULL check (larghezza > 0), /* misure espresse in metri */
	lunghezza		smallint NOT NULL check (lunghezza > 0),
	PRIMARY KEY (codass, id),
	FOREIGN KEY (codass)	REFERENCES Associazione(codice)
);

CREATE TABLE Campo (
	codass			varchar(20),
	id				int,
	cod_sede		int,
	tipologia		int NOT NULL,
	attrezzatura	bool DEFAULT false,
	PRIMARY KEY (codass, id, cod_sede),
	FOREIGN KEY (codass, cod_sede) REFERENCES Sede(codass, codice),
	FOREIGN KEY (codass, tipologia)	REFERENCES tipologia_campo(codass, id)
);

CREATE TABLE prenotazioni (
	codass			varchar(20),
	id_campo		int,
	sede			int,
	id_tesserino	char(16) NOT NULL,
	data			timestamp NOT NULL,
	ore				decimal(2,1) NOT NULL, /* Si possono prenotare solo ore o mezz'ore (mezz'ora = 0.5) */
	arbitro			bool DEFAULT false,
	PRIMARY KEY (codass, id_campo, sede, data),
	FOREIGN KEY (codass, id_campo, sede) REFERENCES Campo(codass, id, cod_sede)
);

CREATE TABLE grado_dipendenti (
	id				int,
	descrizione		varchar(50) NOT NULL,
	PRIMARY KEY (id)
);

CREATE TABLE Dipendente (
	codass				varchar(20),
	cf					char(16),
	nome				varchar(80) NOT NULL,
	cognome				varchar(80) NOT NULL,
	sesso				sessi NOT NULL,
	data_nascita		date NOT NULL,
	email				varchar(80) NOT NULL check (email like '%_@__%.__%'),
	password			varchar(50) NOT NULL,
	telefono			varchar(12),
	grado				int NOT NULL,
	data_assunzione 	date NOT NULL,
	data_fine			date, /* if IS NOT NULL => licenziato/pensione */
	cod_sede			int NOT NULL,
	PRIMARY KEY (codass, cf), /* codass in chiave altrimenti un dipendente non potrebbe cambiare associazione (es. licenziamento) */
	FOREIGN KEY (codass)			REFERENCES Associazione(codice),
	FOREIGN KEY (codass, cod_sede)	REFERENCES Sede(codass, codice),
	FOREIGN KEY (grado)				REFERENCES grado_dipendenti(id)
);

CREATE TABLE Pagamento (
	codass        		varchar(20),
	data        		timestamp,
	id_dipendente    	char(16),
	importo        		money NOT NULL,
	tipo_operazione    	operazioni NOT NULL,
	check (((tipo_operazione='S' or tipo_operazione='E') and importo::numeric < 0) or (tipo_operazione = 'F' and importo::numeric <> 0)),
	PRIMARY KEY (codass, data, id_dipendente), /* codass in chiave per via del licenziamento */
	FOREIGN KEY (codass, id_dipendente) REFERENCES Dipendente(codass, cf)
);
/*
	tipo_operazione:
		F => Fattura
		S => Stipendio
		E => Esborso
*/

CREATE TABLE stipendi (
	codass				varchar(20),
	data				timestamp,
	id_dipendente		char(16),
	soggetto			char(16),		
	PRIMARY KEY (codass, data, id_dipendente, soggetto),
	FOREIGN KEY (codass, data, id_dipendente) REFERENCES Pagamento(codass, data, id_dipendente),
	FOREIGN KEY (codass, soggetto) REFERENCES Dipendente(codass, cf)
);

CREATE TABLE fatture (
	codass				varchar(20),
	data				timestamp,
	id_dipendente		char(16),
	tesserino			char(16) NOT NULL, /* Arbitro o Atleta */
	descrizione			varchar(255),
	progressivo			int check(progressivo >= 0),
	PRIMARY KEY (codass, data, id_dipendente, progressivo),
	FOREIGN KEY (codass, data, id_dipendente) REFERENCES Pagamento(codass, data, id_dipendente),
	FOREIGN KEY (codass, tesserino) REFERENCES Tesserino(codass, cf)
);

CREATE TABLE esborsi (
	codass				varchar(20),
	data				timestamp,
	id_dipendente		char(16),
	id_fornitore		char(16) NOT NULL,
	descrizione			varchar(255),
	PRIMARY KEY (codass, data, id_dipendente, id_fornitore),
	FOREIGN KEY (codass, data, id_dipendente) REFERENCES Pagamento(codass, data, id_dipendente),
	FOREIGN KEY (id_fornitore) REFERENCES Fornitore(piva)
);

ALTER TABLE associazione 		ENABLE TRIGGER ALL;
ALTER TABLE campo 				ENABLE TRIGGER ALL;
ALTER TABLE citta				ENABLE TRIGGER ALL;
ALTER TABLE contratti 			ENABLE TRIGGER ALL;
ALTER TABLE dipendente			ENABLE TRIGGER ALL;
ALTER TABLE esborsi				ENABLE TRIGGER ALL;
ALTER TABLE fatture		 		ENABLE TRIGGER ALL;
ALTER TABLE fornitore			ENABLE TRIGGER ALL;
ALTER TABLE grado_dipendenti	ENABLE TRIGGER ALL;
ALTER TABLE pagamento 			ENABLE TRIGGER ALL;
ALTER TABLE prenotazioni		ENABLE TRIGGER ALL;
ALTER TABLE sede				ENABLE TRIGGER ALL;
ALTER TABLE stipendi 			ENABLE TRIGGER ALL;
ALTER TABLE tesserino			ENABLE TRIGGER ALL;
ALTER TABLE tipologia_campo		ENABLE TRIGGER ALL;
