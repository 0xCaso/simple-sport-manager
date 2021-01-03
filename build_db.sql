CREATE TABLE Associazione (
	codice 		varchar(20),
	ragsoc 		varchar(80) NOT NULL,
	sito		varchar(150) NOT NULL,
	email		varchar(80) NOT NULL,
	password 	varchar(50) NOT NULL,
	PRIMARY KEY(codice)
);

CREATE TABLE Tesserato (
	codass					varchar(20),
	cf						char(16),	/* Fixed */
	nome					varchar(80) NOT NULL,
	cognome					varchar(80) NOT NULL,
	data_nascita			date NOT NULL,
	email					varchar(80) NOT NULL,
	password				varchar(50) NOT NULL,
	telefono				varchar(12), /* con 12 caratteri prendiamo quasi la totalità dei numeri */
	arbitro					bool DEFAULT false,
	data_iscrizione			date NOT NULL,
	scadenza_iscrizione		date NOT NULL,
	sesso 					char(1) NOT NULL,
	PRIMARY KEY(codass, cf),
	FOREIGN KEY (codass) REFERENCES Associazione(codice)
);

/*
CREATE TABLE iscrizione (
	codass					varchar(20),
	id_tesserato 			char(16),
	data_iscrizione			date NOT NULL,
	scadenza_iscrizione		date NOT NULL,
	PRIMARY KEY (codass, id_tesserato),
	FOREIGN KEY (codass) REFERENCES Associazione(codice),
	FOREIGN KEY (id_tesserato) REFERENCES Tesserato(cf)
);
*/

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
	cod_civico 		int NOT NULL
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
	FOREIGN KEY (codass, cod_sede)	REFERENCES Sede(codass, codice),
	FOREIGN KEY (tipologia)			REFERENCES tipologia_campo(id)
);

CREATE TABLE prenotazioni (
	codass			varchar(20),
	id_campo		int,
	sede			int,
	id_tesserato	char(16) NOT NULL,
	data			timestamp NOT NULL,
	ore				float NOT NULL,
	arbitro			bool DEFAULT false,
	PRIMARY KEY (codass, id_campo, sede, data),
	FOREIGN KEY (codass, id_campo, sede) REFERENCES Campo(codass, id, cod_sede)
);

ALTER TABLE prenotazioni
ADD column ore float NOT NULL

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
	sesso				char(1) NOT NULL,
	data_nascita		date NOT NULL,
	email				varchar(80) NOT NULL,
	password			varchar(50) NOT NULL,
	telefono			varchar(12),
	grado				int NOT NULL,
	data_assunzione 	date NOT NULL,
	data_fine			date, /* if IS NOT NULL => licenziato/pensione */
	cod_sede			int,
	PRIMARY KEY (codass, cf), /* codass in chiave altrimenti un dipendente non potrebbe cambiare associazione (es. licenziamento) */
	FOREIGN KEY (codass)			REFERENCES Associazione(codice),
	FOREIGN KEY (codass, cod_sede)	REFERENCES Sede(codass, codice),
	FOREIGN KEY (grado)				REFERENCES grado_dipendenti(id)
);

CREATE TABLE grado_dipendenti (
	id				int,
	descrizione		varchar(50) NOT NULL,
	PRIMARY KEY (id)
)

/*
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
*/

CREATE TABLE Pagamento (
	codass				varchar(20),
	data				timestamp,
	id_dipendente		char(16),
	importo				money NOT NULL,
	tipo_operazione		char(1) NOT NULL,
	PRIMARY KEY (codass, data, id_dipendente), /* codass in chiave sempre per via del licenziamento e coerenza con la PKey del dipendente */
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
	tesserato			char(16) NOT NULL, /* Arbitro o Atleta */
	descrizione			varchar(255),
	progressivo			int,
	PRIMARY KEY (codass, data, id_dipendente, progressivo),
	FOREIGN KEY (codass, data, id_dipendente) REFERENCES Pagamento(codass, data, id_dipendente),
	FOREIGN KEY (codass, tesserato) REFERENCES Tesserato(codass, cf)
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

/* Popolamento associazioni */
INSERT INTO associazione (codice, ragsoc, sito,	email, password)
VALUES
('POLRM', 'Polisportiva Romana', 'polisportivaromana.it', 'info@polisportivaromana.it', 'polisportiva01'),
('JSDB', 'Jesolo San Donà Basket', 'jesolosandonabasket.it', 'info@jsdb.it', 'basket01'),
('CAME', 'Calciatori Mestrini', 'calciomestre.it', 'info@calciomestre.it', 'calcio01');

INSERT INTO associazione (codice, ragsoc, sito,	email, password)
VALUES
('TCPG', 'Tennis Club Portogruaro', 'portogruarotc.it', 'info@pgtc.it', 'tennis01');

/* Popolamento Tesserati */
INSERT INTO tesserato(
codass, cognome, nome, sesso, data_nascita, cf, telefono, email, password, arbitro, data_iscrizione, scadenza_iscrizione)
VALUES 
('JSDB', 'Bonanno', 'Vanda','F','2005-12-31','BNNVND05T71H975W','095/311606','vanda.bonanno@gmail.com','FW93lafaR73G', true, '15/04/2020', '15/04/2022'),
('CAME', 'Biamonte', 'Ondina', 'F', '1969-11-02', 'BMNNDN69S42E423C', '0471/233174', 'ondina.biamonte@gmail.com','XP30mbswL17D', false, '13/10/2019', '13/10/2021'),
('CAME', 'Lattes', 'Cirillo', 'M', '2009-06-20', 'LTTCLL09H20I721H', '0437/888443', 'ciri.latt@libero.it', 'OU57rxvfW86S', false, '14/05/2016', '14/05/2020'),
('CAME', 'Barbon', 'Edvige' , 'F', '1969-11-07', 'BRBDVG69S47B332F', '0932/537114', 'edvi.barb@gmail.com', 'DA84zmrjJ02D', false, '25/03/2018', '25/03/2022'),
('POLRM', 'Lilli', 'Manfredo', 'M', '2013-09-28', 'LLLMFR13P28E390F', '0425/681360', 'm.lilli@teletu.it', 'SV10sodsW95S', false, '13/12/2020', '13/12/2022'),
('POLRM', 'Farronato', 'Zaira', 'F', '1972-05-02', 'FRRZRA72E42E530Z', '0984/236359', 'zaira.farronato@gmail.it', 'EU26buhuR22S', false, '13/12/2020', '13/12/2022'),
('JSDB', 'Tosin','Adelaide','F','1999-05-14','TSNDLD99E54C998K','051/1039499','adelaide.tosin@katamail.it','TJ50rpzrS28Q', false, '03/03/2021', '03/03/2021'),
('JSDB','De Fuschi','Lelia','F','1973-06-03','DFSLLE73H43G184K','0861/185764','lelia.defuschi@gmail.com','EI36vfqfX77R', true, '14/08/2005', '14/08/2008'),
('POLRM','Tessaroli','Giosuè','M','1973-06-28','TSSGSI73H28G190O','030/877912','giosu.tessaroli@tiscali.it','CA19sxssG11N', false, '25/03/2007', '25/03/2021'),
('CAME','Lubatti','Lucia','F','1956-06-13','LBTLCU56H53C659Q','0783/597945','lucia.lubatti@hotmail.com','RX43nuljK66O', false, '26/11/2016', '26/11/2021'),
('JSDB','Berisso','Sveva','F','2013-10-19','BRSSVV13R59C631F','0823/453009','sveva.berisso@gmail.it','UT20qvhkF22K', false, '15/07/2021', '15/07/2022'),
('JSDB','Terenzi','Pierluigi','M','2000-03-21','TRNPLG00C21B166C','0984/550396','pierluigi.terenzi@virgilio.it','TO37zfmkK45H', false, '15/07/2021', '15/07/2022'),
('CAME','Bernasconi','Omero','M','1973-09-22','BRNMRO73P22G619O','0733/104205','omero.bernasconi@teletu.it','XT61tpyuH60X', false, '15/07/2021', '15/07/2022'),
('JSDB','Bertolli','Bruto','M','2009-01-23','BRTBRT09A23A261M','02/1048133','bruto.bertolli@teletu.it','EI01lvzhA06G', true, '15/07/2021', '15/07/2022'),
('POLRM','Peppe','Celso','M','1973-12-25','PPPCLS73T25L810W','011/1090772','celso.peppe@katamail.it','KD13itfqD85J', false, '03/03/2021', '03/03/2023'),
('CAME','Minelli','Filomena','F','1975-05-25','MNLFMN75E65E976M','045/247375','filo.mine@yahoo.it','PX47maioZ32M', false, '03/03/2021', '03/03/2023'),
('JSDB','Gaucci','Siro','M','1985-05-24','GCCSRI85E24A067U','0376/1048271','siro.gaucci@tiscali.it','SY97zcwyQ86X', false, '03/03/2021', '03/03/2023'),
('JSDB','Massarenti','Renata','F','1992-12-19','MSSRNT92T59H534R','0761/311992','renata.massarenti@libero.it','DM89rzfkY86M', false, '15/01/2009', '15/01/2021'),
('CAME','Boero','Sibilla','F','1987-03-19','BROSLL87C59A562M','0161/399955','sibilla.boero@gmail.it','LT57bbgcT60S', true, '14/01/2003', '14/01/2021'),
('JSDB','Morocutti','Vilma','F','2017-07-06','MRCVLM17L46B131H','0432/656364','vilma.morocutti@teletu.it','FJ53stjuH42L', false, '25/02/2018', '25/02/2019'),
('JSDB','Retusi','Ezechiele','M','2002-03-15','RTSZHL02C15B984X','0775/154789','ezechiele.retusi@virgilio.it','GR69vdxqX31R', false, '13/01/2019', '13/04/2019'),
('CAME','Moncada','Brando','M','2012-02-06','MNCBND12B06A227X','0522/605708','bran.monc@tin.it','AG76yqnqH97Z', false, '20/04/2021', '20/04/2022'),
('JSDB','Camosso','Demetrio','M','1983-10-11','CMSDTR83R11H743Z','0161/871364','deme.camo@gmail.com','SX26qbfcB27Q', false, '20/04/2021', '20/08/2021'),
('CAME','Gabriel','Amilcare','M','1953-10-06','GBRMCR53R06D703U','0161/849694','amil.gabr@katamail.it','DK67bsvcT88U', true, '05/05/2017', '05/05/2018'),
('POLRM','Antonicello','Annagrazia','F','1956-04-15','NTNNGR56D55D668J','035/906471','a.antonicello@tin.it','PP61pxxdV09N', false, '07/12/2021', '07/12/2023'),
('JSDB','Berard','Eros','M','1983-05-17','BRRRSE83E17E630A','0461/706585','eros.berard@katamail.it','TL06glbwE09A', false, '12/9/2012', '12/9/2013'),
('JSDB','Galiani','Norina','F','1943-03-25','GLNNRN43C65D398Y','0783/410414','norina.galiani@tin.it','GI52fyhnH18W', true, '03/03/1999', '03/03/2005'),
('POLRM','Barone','Noemi','F','2012-08-31','BRNNMO12M71E893S','06/833110','noem.baro@aruba.it','MU06xljzJ94G', false, '03/03/2021', '03/03/2022'),
('CAME','Lange','Emanuele','M','1980-07-13','LNGMNL80L13C387K','0524/865784','emanuele.lange@yahoo.com','GA28euvzV87I', false, '03/03/2021', '03/03/2023'),
('POLRM', 'Raimondo', 'Pantelli', 'M','1984-04-30','PNTRND84D30H108A','0824/1009494','raimondo.pantelli@yahoo.com','JN83lxzdV76Z', false, '12/06/2018', '12/06/2020');

insert into tesserato (codass,cognome,nome,sesso,data_nascita,cf,telefono,email,password,arbitro,data_iscrizione,scadenza_iscrizione)
values ('TCPG','Sabbatelli','Mirko','M','2000-11-19','SBBMRK17S19F961M','035/539737','mirko.sabbatelli@virgilio.it','UA90vjatO35R',false,' 31/12/2020',' 11/05/2022');

insert into tesserato (codass,cognome,nome,sesso,data_nascita,cf,telefono,email,password,arbitro,data_iscrizione,scadenza_iscrizione)
values ('TCPG','Mazzolini','Ulrico','M','1995-01-26','MZZLRC35A26A038K','0372/213476','ulrico.mazzolini@hotmail.com','GK40okdlP09V',true,' 22/10/2019',' 08/07/2022');

insert into tesserato (codass,cognome,nome,sesso,data_nascita,cf,telefono,email,password,arbitro,data_iscrizione,scadenza_iscrizione)
values ('TCPG','Vargiu','Daniele','M','1990-08-19','VRGDNL10M19E727A','02/1067185','daniele.vargiu@tele2.it','ZE21ovjuU79O',false,' 29/06/2020',' 08/07/2022');

insert into tesserato (codass,cognome,nome,sesso,data_nascita,cf,telefono,email,password,arbitro,data_iscrizione,scadenza_iscrizione)
values ('TCPG','Maragnano','Decimo','M','1982-02-01','MRGDCM12B01H242P','02/793234','deci.mara@yahoo.it','BL18lbfiE35Q',true,' 23/09/2019',' 11/05/2022');

insert into tesserato (codass,cognome,nome,sesso,data_nascita,cf,telefono,email,password,arbitro,data_iscrizione,scadenza_iscrizione)
values ('TCPG','Cavioni','Marinella','F','1981-08-23','CVNMNL81M63L817G','035/258064','marinella.cavioni@tele2.it','WQ64hhbeQ06E',false,' 14/08/2020',' 29/08/2023');

insert into tesserato (codass,cognome,nome,sesso,data_nascita,cf,telefono,email,password,arbitro,data_iscrizione,scadenza_iscrizione)
values ('TCPG','Guglielmetti','Mosè','M','1996-06-24','GGLMSO96H24A444K','089/948950','mos.guglielmetti@teletu.it','PN40iozpL49Z',false,' 31/12/2020',' 07/12/2022');

insert into tesserato (codass,cognome,nome,sesso,data_nascita,cf,telefono,email,password,arbitro,data_iscrizione,scadenza_iscrizione)
values ('TCPG','Fioravanzi','Loris','M','1981-10-12','FRVLRS81R12I482L','0372/1039860','lori.fior@tiscali.it','BN74tlzaR29W',false,' 15/12/2020',' 21/02/2022');

insert into tesserato (codass,cognome,nome,sesso,data_nascita,cf,telefono,email,password,arbitro,data_iscrizione,scadenza_iscrizione)
values ('TCPG','Iaconelli','Tamara','F','1971-04-11','CNLTMR61D51L238M','055/753391','tama.iaco@hotmail.com','ZO24zppuM66V',true,'01/01/2019','14/01/2022');

insert into tesserato (codass,cognome,nome,sesso,data_nascita,cf,telefono,email,password,arbitro,data_iscrizione,scadenza_iscrizione)
values ('TCPG','Gattinara','Orsola','F','1992-10-03','GTTRSL02R43H939G','085/861691','orsola.gattinara@gmail.com','LJ35bocpF51T',false,' 28/10/2019',' 23/11/2023');

insert into tesserato (codass,cognome,nome,sesso,data_nascita,cf,telefono,email,password,arbitro,data_iscrizione,scadenza_iscrizione)
values ('TCPG','Altinier','Pia','F','1996-08-22','LTNPIA36M62H414P','080/644749','pia.altinier@tiscali.it','HU72tpcdE75N',true,' 17/09/2019',' 06/07/2022');


/* Popolamento Sedi */
INSERT INTO sede (codass, codice, via, cod_civico, cod_citta, nome, telefono)
VALUES
('CAME', 1, 'Via E.Ponti', 28, '27042', 'Sede Pulcini Calcio Mestre', '045/570483'),
('CAME', 2, 'Via Antonio Vallisneri', 43, '27042', 'Sede Calcio Mestre', '0141/1004036'),
('JSDB', 1, 'Via Iseo', 2, '27033', 'Jesolo San Donà Basket', '0421/5567423'),
('JSDB', 2, 'Via Tredici Martiri', 15, '27027', 'Jesolo San Donà Basket (Noventa)', '0421/5564472'),
('POLRM', 1, 'Viale Tevere', 96, '58104', 'Polisportiva Roma (Tivoli)', '0564/803071');

INSERT INTO sede (codass, codice, via, cod_civico, cod_citta, nome, telefono)
VALUES
('TCPG', 1, 'Via Alberti', 72, '27029', 'Tennis Club Portogruaro', '0564/803071'),
('TCPG', 2, 'Via Verdi', 43, '27029', 'Tennis Club Portogruaro (Portovecchio)', '0564/378254');

/* Popolamento fornitori */
INSERT INTO fornitore (piva, ragione_soc, email, telefono)
VALUES
('06500120016', 'Molten Italia', 'd.carta@advanced-distribution.com', '0118005901'),
('05126523875', 'Wilson Italia', 'info@wilson.com', '3345879854'),
('07762523875', 'Adidas', 'd.prod@adidas.com', '3645479884'),
('04512794513', 'Nike', 'd.prod@nike.com', '0645446914');

INSERT INTO fornitore (piva, ragione_soc, email, telefono)
VALUES
('06456486415', 'Babolat Italia', 'support@babolat.it', '3347541878'),
('08794512358', 'ATP', 'info@atp.com', '3985623145');

/* Registrazioni contratti */
INSERT INTO contratti (codass, cod_fornitore, data_inizio)
VALUES
('JSDB', '06500120016', '23/03/2005'),
('JSDB', '05126523875', '12/09/2009'),
('CAME', '06500120016', '5/06/2009'),
('CAME', '04512794513', '5/06/2007'),
('POLRM', '05126523875', '25/10/2015'),
('POLRM', '06500120016', '5/08/2015'),
('POLRM', '04512794513', '13/06/2015');

INSERT INTO contratti (codass, cod_fornitore, data_inizio)
VALUES
('TCPG', '05126523875', '13/06/2020'),
('TCPG', '06456486415', '3/02/2017'),
('TCPG', '08794512358', '22/09/2016');

/* Specifiche sulla gerarchia dei dipendenti */
INSERT INTO grado_dipendenti
VALUES
(10, 'Segreteria'),
(20, 'Responsabile'),
(30, 'Amministrazione');

/* Popolamento dipendenti */ 
INSERT INTO dipendente (codass, cognome, nome, sesso, data_nascita, cf, telefono, email, password, grado, data_assunzione, data_fine, cod_sede)
VALUES
('JSDB', 'Bertugli','Giovanna','F','1998-09-05','BRTGNN98P45C524P','0376/270098','giovanna.bertugli@gmail.com','BQ88vibxC77P', 10, '2012-12-15', NULL, 1),
('POLRM', 'Musumeci','Aristotele','M','1997-10-11','MSMRTT97R11C661I','0131/640624','amusumeci@gmail.com','RR90vaugW52R', 20, '2013-11-16', NULL, 1),
('CAME', 'Sacchino','Tancredi','M','1993-08-24','SCCTCR93M24L183J','0721/319561','tancredi.sacchino@gmail.com','HK49hsubV04U', 10, '2014-9-25', NULL, 2),
('JSDB', 'Trapattoni','Emilio','M','1988-06-02','TRPMLE88H02L696X','0437/824923','etrapattoni@gmail.com','YM40btbiT75H', 30, '2015-5-14', NULL, 2),
('JSDB', 'Gabriele','Clelia','F','1996-05-25','GBRCLL96E65F726F','011/664877','clel.gabr@gmail.com','KR96xwrdB91C', 10, '2016-6-23', NULL, 2),
('JSDB', 'Coloso','Enrica','F','1993-11-29','CLSNRC93S69H949L','031/966744','enri.colo@gmail.com','DD81pfgbS30N', 20, '2017-7-9', NULL, 2),
('POLRM', 'Folletti','Angela','F','1991-10-17','FLLNGL91R57E148Q','0141/641067','angela.folletti@gmail.com','JL25jtouC34I', 30, '2018-2-14', NULL, 1),
('CAME', 'Baracco','Gastone','M','1993-01-23','BRCGTN93A23A193B','0131/963721','gastone.baracco@gmail.com','ID41kcaeC65C', 10, '2019-3-8', NULL, 2),
('JSDB', 'Fineschi','Antonio','M','1986-10-26','FNSNTN86R26I968A','0932/830244','antonio.fineschi@gmail.com','ZB86fbwvD06V', 20, '2013-4-28', NULL, 2),
('CAME', 'Piccinino','Camilla','F','1998-09-01','PCCCLL98P41G276S','0934/811002','camilla.piccinino@gmail.com','CU87lwgoC12Q', 30, '2014-5-29', NULL, 1),
('JSDB', 'Ansalone','Sandra','F','1989-10-10','NSLSDR89R50L319K','011/953432','sand.ansa@gmail.com','MK91ihgtJ67O', 10, '2015-1-15', NULL, 1),
('JSDB', 'Antacido','Lea','F','2000-04-12','NTCLEA00D52F486P','0382/1020624','lea.antacido@gmail.com','QN08wsarN16A', 20, '2016-8-1', NULL, 2),
('CAME', 'Demattio','Giuda','M','1994-11-09','DMTGDI94S09E669C','0934/589832','giuda.demattio@gmail.com','NO89cobaY12S', 30, '2017-9-17', NULL, 1),
('POLRM', 'Albricci','Emiliana','F','1988-02-12','LBRMLN88B52A690A','035/964080','emil.albr@gmail.com','NY96oseyG00J', 10, '2018-6-18', NULL, 1),
('JSDB', 'Taiani','Giacomo','M','1987-08-26','TNAGCM87M26M030Z','0743/750731','giacomo.taiani@gmail.com','WF35rodwW27H', 20, '2013-4-5', NULL, 1),
('CAME', 'Molignani','Giovanna','F','1987-09-21','MLGGNN87P61D688H','091/942269','giovanna.molignani@gmail.com','JJ00dqveM82K', 30, '2014-7-6', NULL, 2),
('JSDB', 'Rezzoagli','Lea','F','1993-03-04','RZZLEA93C44F385V','0444/641397','lea.rezz@gmail.com','HJ65anksF11C', 10, '2015-4-7', NULL, 1),
('POLRM', 'Bascio','Ercole','M','1988-06-09','BSCRCL88H09G520N','0861/731265','ercole.bascio@gmail.com','QJ69kstgO17I', 20, '2014-4-8', NULL, 1),
('JSDB', 'Bebbo','Alfredo','M','1994-05-18','BBBLRD94E18F315Z','0871/887969','alfredo.bebbo@gmail.com','VX19xxkqW61V', 30, '2014-3-9', NULL, 1),
('CAME', 'Luzardi','Cornelio','M','1985-06-01','LZRCNL85H01B595R','0881/893745','corn.luza@gmail.com','UE41vppaU07O', 10, '2013-11-10', '2020-08-12', 2),
('JSDB', 'Garzelli','Ancilla','F','1985-10-20','GRZNLL85R60C685E','0382/567014','a.garzelli@gmail.com','IW32qazgV86A', 20, '2017-12-11', NULL, 1),
('JSDB', 'Ponzoni','Caino','M','1987-01-24','PNZCNA87A24M060P','045/351924','caino.ponzoni@gmail.com','CP30chieO96O', 30, '2016-4-12', NULL, 2),
('POLRM', 'Andideri','Maddalena','F','1999-12-22','NDDMDL99T62F762S','0831/921349','m.andideri@gmail.com','ED83rksfM45Y', 10, '2015-3-13', NULL, 1),
('JSDB', 'Solero','Modesto','M','2000-01-07','SLRMST00A07F769M','0161/811356','modesto.solero@gmail.com','KZ92gqqfA39L', 20, '2013-11-14', NULL, 2),
('CAME', 'Gangi','Nereo','M','1995-12-21','GNGNRE95T21G382G','0372/448135','nereo.gangi@gmail.com','UP17rhehD68F', 30, '2020-10-15', NULL, 1),
('POLRM', 'Polucci','Fabiola','F','1997-09-11','PLCFBL97P51F651S','0165/534849','f.polucci@gmail.com','EZ51smbtO20O', 10, '2021-10-16', NULL, 1),
('JSDB', 'Grispo','Marta','F','1989-05-13','GRSMRT89E53G048G','0784/341544','marta.grispo@gmail.com','ON95gsugX20Y', 20, '2020-7-17', NULL, 1),
('CAME', 'Laviano','Alba','F','1986-07-18','LVNLBA86L58F216F','0372/350332','alba.laviano@gmail.com','GT63rocrF92R', 30, '2019-8-18', NULL, 2),
('POLRM', 'Poli','Tolomeo','M','1995-09-23','PLOTLM95P23F717I','011/651116','tolomeo.poli@gmail.com','ZQ93svkiD41L', 10, '2018-9-19', NULL, 1);

insert into dipendente (codass,cognome,nome,sesso,data_nascita,cf,telefono,email,password,grado,data_assunzione,data_fine,cod_sede)
values ('TCPG','Carobbio','Baldassarre','M','1985-08-15','CRBBDS85M15E507I','0736/659335','bald.caro@hotmail.com','UL62fzqlR36O',10,' 28/12/2015',' 12/10/2022',1);

insert into dipendente (codass,cognome,nome,sesso,data_nascita,cf,telefono,email,password,grado,data_assunzione,data_fine,cod_sede)
values ('TCPG','Fugazzi','Arnaldo','M','2000-10-30','FGZRLD00R30H395L','0543/193304','arnaldo.fugazzi@gmail.com','UD65smjwZ09G',20,' 02/08/2012',' 23/08/2017',2);

insert into dipendente (codass,cognome,nome,sesso,data_nascita,cf,telefono,email,password,grado,data_assunzione,data_fine,cod_sede)
values ('TCPG','Onofrio','Adriana','F','1989-10-19','NFRDRN89R59L535D','049/721393','adriana.onofrio@gmail.com','JX23zfdtI23O',30,' 24/11/2016',' 18/07/2019',1);

insert into dipendente (codass,cognome,nome,sesso,data_nascita,cf,telefono,email,password,grado,data_assunzione,data_fine,cod_sede)
values ('TCPG','Petrazzuolo','Dante','M','1994-07-06','PTRDNT94L06G428W','0382/1051382','d.petrazzuolo@gmail.com','AI29ycsnN64G',10,' 28/12/2015',' 14/11/2017',2);

insert into dipendente (codass,cognome,nome,sesso,data_nascita,cf,telefono,email,password,grado,data_assunzione,data_fine,cod_sede)
values ('TCPG','Amedei','Minerva','F','1991-02-26','MDAMRV91B66C187D','0984/286769','minerva.amedei@libero.it','WU47thmgX16C',20,' 29/06/2015',' 22/09/2017',1);

insert into dipendente (codass,cognome,nome,sesso,data_nascita,cf,telefono,email,password,grado,data_assunzione,data_fine,cod_sede)
values ('TCPG','Quintarelli','Gerardo','M','1998-03-08','QNTGRD98C08F655L','049/971795','g.quintarelli@tele2.it','UK26cmfsN62K',30,' 29/06/2015',' 22/09/2017',2);

insert into dipendente (codass,cognome,nome,sesso,data_nascita,cf,telefono,email,password,grado,data_assunzione,data_fine,cod_sede)
values ('TCPG','Minozzi','Omero','M','1997-11-22','MNZMRO97S22M119N','0523/214353','omero.minozzi@tiscali.it','EL04hebjP68A',10,' 21/03/2014',' 22/09/2017',1);

insert into dipendente (codass,cognome,nome,sesso,data_nascita,cf,telefono,email,password,grado,data_assunzione,data_fine,cod_sede)
values ('TCPG','Meloncelli','Margherita','F','1983-08-26','MLNMGH83M66B204D','011/558535','margherita.meloncelli@yahoo.com','QO60mdehP30Z',20,' 07/05/2014',' 24/08/2022',2);

insert into dipendente (codass,cognome,nome,sesso,data_nascita,cf,telefono,email,password,grado,data_assunzione,data_fine,cod_sede)
values ('TCPG','Arbizzani','Ferdinando','M','2001-07-23','RBZFDN01L23F918O','035/812848','ferdinando.arbizzani@lycos.it','UY60kdlrQ49Q',30,' 07/10/2015',' 28/01/2021',1);

insert into dipendente (codass,cognome,nome,sesso,data_nascita,cf,telefono,email,password,grado,data_assunzione,data_fine,cod_sede)
values ('TCPG','Tagliafierro','Romolo','M','1991-05-23','TGLRML91E23D578W','035/125471','romolo.tagliafierro@gmail.com','HE87dnjnA83N',10,' 07/02/2013',' 22/09/2017',2);

INSERT INTO tipologia_campo (codass, id, sport, terreno, larghezza, lunghezza)
VALUES
('JSDB', 1, 'Basket', 'parquet', 15, 28),
('JSDB', 2, 'Basket', 'parquet', 14, 27),
('CAME', 1, 'Calcio', 'erba', 90, 120),
('CAME', 2, 'Calcio', 'erba', 65, 105),
('CAME', 3, 'Calcio', 'erba', 60, 100),
('POLRM', 1, 'Calcio', 'erba', 65, 105),
('POLRM', 2, 'Calcio 5', 'gomma', 15, 25),
('POLRM', 3, 'Calcio 5', 'erba sintetica', 22, 42),
('POLRM', 4, 'Calcio 7', 'erba sintetica', 30, 50),
('POLRM', 5, 'Calcio 8', 'erba', 40, 60),
('POLRM', 6, 'Basket', 'parquet', 15, 28),
('POLRM', 7, 'Basket 3', 'gomma', 15, 11);

INSERT INTO tipologia_campo (codass, id, sport, terreno, larghezza, lunghezza)
VALUES
('TCPG', 1, 'Tennis', 'terra battuta', 11, 24),
('TCPG', 2, 'Tennis', 'erba', 11, 24),
('TCPG', 3, 'Tennis', 'erba sintetica', 11, 24),
('TCPG', 4, 'Tennis', 'cemento', 11, 24);

/*
	Calcio:
		- 65 x 105 (misure minime)
		- 60 x 100 (casi eccezionali)
	Calcio 5:
		- 15 x 25
		- 22 x 42
	Calcio 7:
		- 44-65 delta lunghezza
		- 25-40 delta larghezza
	Calcio 8:
		- 35-45 delta larghezza
		- 55-70 delta lunghezza
		
	Basket 5vs5:
		- 15 x 28
	Basket 3vs3:
		- 15 x 11
		
	Tennis:
		-  8,23 x 23,77 (SINGOLO)
		- 10,97 x 23,77 (DOPPIO)
		
		- superfici:
			terra battuta, terra verde, erba, erba sintetica, cemento, sintetico
			
	Pallavolo:
		- 9 x 18
		
		- terreno:
			parquet, pvc, gomma, sabbia, cemento
*/

INSERT INTO campo (codass, id, cod_sede, tipologia, attrezzatura)
VALUES
('JSDB', 1, 1, 1, true),
('JSDB', 2, 1, 2, true),
('JSDB', 1, 2, 1, true),
('CAME', 1, 1, 2, true),
('CAME', 2, 1, 2, true),
('CAME', 1, 2, 3, true),
('POLRM', 1, 1, 1, true),
('POLRM', 2, 1, 2, true),
('POLRM', 3, 1, 3, true),
('POLRM', 4, 1, 4, true),
('POLRM', 5, 1, 5, true),
('POLRM', 6, 1, 6, true),
('POLRM', 7, 1, 5, true),
('POLRM', 8, 1, 6, true),;

INSERT INTO campo (codass, id, cod_sede, tipologia, attrezzatura)
VALUES
('TCPG', 1, 1, 1, true),
('TCPG', 2, 1, 2, true),
('TCPG', 3, 1, 3, true),
('TCPG', 4, 1, 4, true),
('TCPG', 1, 2, 1, true),
('TCPG', 2, 2, 3, true);

/*

ATTANSION (vincolo di integrità da aggiungere):
Su stipendi/fatture/esborsi --> id dipendente deve essere di un dipendente del grado giusto
								(esempio --> fatture gestite esclusivamente da dipendenti con grado associato a "segreteria")
							--> inoltre la chiave codass-data-id_dipendente deve corrispondere a una tupla su "pagamento"
								la quale dovrà avere il giusto tipo di operazione
								
*/

INSERT INTO pagamento (codass, data, id_dipendente, importo, tipo_operazione)
VALUES
('JSDB', '12/04/2021', 'BBBLRD94E18F315Z', '-3000,65', 'S');

INSERT INTO pagamento (codass, data, id_dipendente, importo, tipo_operazione)
VALUES
('TCPG', '22/02/2021', 'NFRDRN89R59L535D', '-2500,65', 'S'),
('TCPG', '18/08/2020', 'NFRDRN89R59L535D', '-2750,80', 'S'),
('TCPG', '29/05/2019', 'QNTGRD98C08F655L', '-2880,05', 'S'),
('TCPG', '04/01/2020', 'QNTGRD98C08F655L', '-3220,20', 'S');

INSERT INTO stipendi (codass, data, id_dipendente, soggetto)
VALUES
('JSDB', '12/04/2021', 'BBBLRD94E18F315Z', 'BRTGNN98P45C524P');

INSERT INTO stipendi (codass, data, id_dipendente, soggetto)
VALUES
('TCPG', '22/02/2021', 'NFRDRN89R59L535D', 'QNTGRD98C08F655L'),
('TCPG', '18/08/2020', 'NFRDRN89R59L535D', 'MDAMRV91B66C187D'),
('TCPG', '29/05/2019', 'QNTGRD98C08F655L', 'TGLRML91E23D578W'),
('TCPG', '04/01/2020', 'QNTGRD98C08F655L', 'PTRDNT94L06G428W');

INSERT INTO prenotazioni (codass, id_campo, sede, id_tesserato, data, ore, arbitro)
VALUES

('POLRM', 1, 1, 'PPPCLS73T25L810W', '17-05-2020 18:00', 2,true),
('POLRM', 3, 1, 'TSSGSI73H28G190O', '17-05-2020 16:30', 2,false),
('POLRM', 4, 1, 'BRNNMO12M71E893S', '17-05-2020 15:30', 1.5,false),
('POLRM', 4, 1, 'NTNNGR56D55D668J', '17-05-2020 17:30', 2,false),
('POLRM', 3, 1, 'PNTRND84D30H108A', '17-05-2020 18:30', 1,false),
('POLRM', 4, 1, 'FRRZRA72E42E530Z', '17-05-2020 14:30', 2,false),

('POLRM', 1, 1, 'PPPCLS73T25L810W', '20-05-2020 18:00', 2, true),
('POLRM', 3, 1, 'TSSGSI73H28G190O', '20-05-2020 16:30', 2, false),
('POLRM', 4, 1, 'BRNNMO12M71E893S', '20-05-2020 15:30', 1.5, false),
('POLRM', 4, 1, 'NTNNGR56D55D668J', '20-05-2020 17:30', 2, false),
('POLRM', 3, 1, 'PNTRND84D30H108A', '20-05-2020 18:30', 1, false),
('POLRM', 4, 1, 'FRRZRA72E42E530Z', '20-05-2020 14:30', 2, false),

('POLRM', 1, 1, 'PPPCLS73T25L810W', '25-05-2020 18:00', 2, true),
('POLRM', 3, 1, 'TSSGSI73H28G190O', '25-05-2020 16:30', 2, false),
('POLRM', 4, 1, 'BRNNMO12M71E893S', '25-05-2020 15:30', 1.5, false),
('POLRM', 4, 1, 'NTNNGR56D55D668J', '25-05-2020 17:30', 2, false),
('POLRM', 3, 1, 'PNTRND84D30H108A', '25-05-2020 18:30', 1, false),
('POLRM', 4, 1, 'FRRZRA72E42E530Z', '25-05-2020 14:30', 2, false),

('POLRM', 1, 1, 'PPPCLS73T25L810W', '30-05-2020 18:00', 2, true),
('POLRM', 3, 1, 'TSSGSI73H28G190O', '30-05-2020 16:30', 2, false),
('POLRM', 4, 1, 'BRNNMO12M71E893S', '30-05-2020 15:30', 1.5, false),
('POLRM', 4, 1, 'NTNNGR56D55D668J', '30-05-2020 17:30', 2, false),
('POLRM', 3, 1, 'PNTRND84D30H108A', '30-05-2020 18:30', 1, false),
('POLRM', 4, 1, 'FRRZRA72E42E530Z', '30-05-2020 14:30', 2, false),

('POLRM', 1, 1, 'PPPCLS73T25L810W', '10-07-2020 18:00', 2, true),
('POLRM', 3, 1, 'TSSGSI73H28G190O', '10-7-2020 16:30', 2, false),
('POLRM', 4, 1, 'BRNNMO12M71E893S', '10-7-2020 15:30', 1.5, false),
('POLRM', 4, 1, 'NTNNGR56D55D668J', '10-7-2020 17:30', 2, false),
('POLRM', 3, 1, 'PNTRND84D30H108A', '10-7-2020 18:30', 1, false),
('POLRM', 4, 1, 'FRRZRA72E42E530Z', '10-7-2020 14:30', 2, false),

('POLRM', 1, 1, 'PPPCLS73T25L810W', '15-07-2020 18:00', 2, true),
('POLRM', 3, 1, 'TSSGSI73H28G190O', '15-7-2020 16:30', 2, false),
('POLRM', 4, 1, 'BRNNMO12M71E893S', '15-7-2020 15:30', 1.5, false),
('POLRM', 4, 1, 'NTNNGR56D55D668J', '15-7-2020 17:30', 2, false),
('POLRM', 3, 1, 'PNTRND84D30H108A', '15-7-2020 18:30', 1, false),
('POLRM', 4, 1, 'FRRZRA72E42E530Z', '15-7-2020 14:30', 2, false),

('POLRM', 1, 1, 'PPPCLS73T25L810W', '18-07-2020 18:00', 2, true),
('POLRM', 3, 1, 'TSSGSI73H28G190O', '18-7-2020 16:30', 2, false),
('POLRM', 4, 1, 'BRNNMO12M71E893S', '18-7-2020 15:30', 1.5, false),
('POLRM', 4, 1, 'NTNNGR56D55D668J', '18-7-2020 17:30', 2, false),
('POLRM', 3, 1, 'PNTRND84D30H108A', '18-7-2020 18:30', 1, false),
('POLRM', 4, 1, 'FRRZRA72E42E530Z', '18-7-2020 14:30', 2, false),

('POLRM', 1, 1, 'PPPCLS73T25L810W', '22-07-2020 18:00', 2, true),
('POLRM', 3, 1, 'TSSGSI73H28G190O', '22-7-2020 16:30', 2, false),
('POLRM', 4, 1, 'BRNNMO12M71E893S', '22-7-2020 15:30', 1.5, false),
('POLRM', 4, 1, 'NTNNGR56D55D668J', '22-7-2020 17:30', 2, false),
('POLRM', 3, 1, 'PNTRND84D30H108A', '22-7-2020 18:30', 1, false),
('POLRM', 4, 1, 'FRRZRA72E42E530Z', '22-7-2020 14:30', 2, false),

('POLRM', 1, 1, 'PPPCLS73T25L810W', '28-07-2020 18:00', 2, true),
('POLRM', 3, 1, 'TSSGSI73H28G190O', '28-7-2020 16:30', 2, false),
('POLRM', 4, 1, 'BRNNMO12M71E893S', '28-7-2020 15:30', 1.5, false),
('POLRM', 4, 1, 'NTNNGR56D55D668J', '28-7-2020 17:30', 2, false),
('POLRM', 3, 1, 'PNTRND84D30H108A', '28-7-2020 18:30', 1, false),
('POLRM', 4, 1, 'FRRZRA72E42E530Z', '28-7-2020 14:30', 2, false),


('POLRM', 5, 1, 'PPPCLS73T25L810W', '18-07-2020 18:00', 2, true),
('POLRM', 6, 1, 'TSSGSI73H28G190O', '18-7-2020 16:30', 2, false),
('POLRM', 5, 1, 'BRNNMO12M71E893S', '18-7-2020 15:30', 1.5, false),
('POLRM', 6, 1, 'NTNNGR56D55D668J', '18-7-2020 17:30', 2, false),
('POLRM', 5, 1, 'PNTRND84D30H108A', '18-7-2020 18:30', 1, false),
('POLRM', 6, 1, 'FRRZRA72E42E530Z', '18-7-2020 14:30', 2, false),

('POLRM', 5, 1, 'PPPCLS73T25L810W', '20-07-2020 18:00', 2, true),
('POLRM', 6, 1, 'TSSGSI73H28G190O', '20-7-2020 16:30', 2, false),
('POLRM', 5, 1, 'BRNNMO12M71E893S', '20-7-2020 15:30', 1.5, false),
('POLRM', 6, 1, 'NTNNGR56D55D668J', '20-7-2020 17:30', 2, false),
('POLRM', 5, 1, 'PNTRND84D30H108A', '20-7-2020 18:30', 1, false),
('POLRM', 6, 1, 'FRRZRA72E42E530Z', '20-7-2020 14:30', 2, false),

('POLRM', 5, 1, 'PPPCLS73T25L810W', '12-07-2020 18:00', 2, true),
('POLRM', 6, 1, 'TSSGSI73H28G190O', '12-7-2020 16:30', 2, false),
('POLRM', 5, 1, 'BRNNMO12M71E893S', '12-7-2020 15:30', 1.5, false),
('POLRM', 6, 1, 'NTNNGR56D55D668J', '12-7-2020 17:30', 2, false),
('POLRM', 5, 1, 'PNTRND84D30H108A', '12-7-2020 18:30', 1, false),
('POLRM', 6, 1, 'FRRZRA72E42E530Z', '12-7-2020 14:30', 2, false),
('POLRM', 5, 1, 'BRNNMO12M71E893S', '12-7-2020 10:30', 2, false),

('POLRM', 1, 1, 'LLLMFR13P28E390F', '15-05-2020 16:30', 1, false),

('POLRM', 1, 1, 'PPPCLS73T25L810W', '15-05-2020 18:00', 2, true),
('POLRM', 3, 1, 'TSSGSI73H28G190O', '15-05-2020 16:30', 2, false),
('POLRM', 4, 1, 'BRNNMO12M71E893S', '15-05-2020 15:30', 1.5, false),
('POLRM', 4, 1, 'NTNNGR56D55D668J', '15-05-2020 17:30', 2, false),
('POLRM', 3, 1, 'PNTRND84D30H108A', '15-05-2020 18:30', 1, false),
('POLRM', 4, 1, 'FRRZRA72E42E530Z', '15-05-2020 14:30', 2, false);


select *
from pagamento







