/*
	Per compilare:
							g++ codice.cpp -L dependencies\lib -lpq -o codice

	Altrimenti la libreria causa errori e non compila più

*/

#include <cstdio>
#include <iostream>
#include <fstream>
#include "dependencies/include/libpq-fe.h"
//#include <string>

using namespace std;

#define PG_HOST 	"127.0.0.1"
#define PG_USER 	"postgres"
#define PG_DB 		"delivery"
#define PG_PASS 	"admin$23"
#define PG_PORT		5432


void checkResults(PGresult* res, const PGconn* conn){
	if(PQresultStatus(res) != PGRES_TUPLES_OK) {
		cout << "Risultati inconsistenti! " << PQerrorMessage(conn) << endl;
		PQclear(res);
		exit(1);
	}
}

int main ( int argc , char ** argv ) {

	char conninfo[250];

	sprintf(conninfo, "user=%s password=%s dbname=%s hostaddr=%s port=%d", PG_USER, PG_PASS, PG_DB, PG_HOST, PG_PORT);

	PGconn * conn ;
	conn = PQconnectdb (conninfo);

	if(PQstatus(conn) != CONNECTION_OK){
		cout << "Errore di connessione " << PQerrorMessage(conn);
		//PQfinish(conn);
		//exit(1);
	} else {
		cout << "Connessione avvenuta correttamente\n";

		string query = "SELECT origin, destination, departure_time, arrival_time FROM hubs JOIN legs on origin=hub WHERE country=$1::varchar";

		PGresult * stmt = PQprepare(conn ,"query_legs", query.c_str() , 1, NULL);

		string country; // parametro
		cout << "Inserire codice paese di origine: ";
		cin >> country;
		const char * parameter = country.c_str();

		PGresult* res;
		res = PQexecPrepared(conn, "query_legs", 1, &parameter, NULL, 0, 0); 
		checkResults(res, conn);

/*
		PGresult* res = PQexec(conn, "SELECT * FROM hubs");
		PGresult* stmt = PQprepare(conn, "hubs4country", "SELECT * FROM hubs WHERE country = $1::varchar", 1, NULL);
		PGresult* res = PQexecPrepared(conn, "hubs4country", 1, &parameter, NULL, 0, 0);

		checkResults(res, conn);

		// se sono qui i dati che ho ottenuto sono corretti
*/
		cout << "Stampa: \n";
		int tuple = PQntuples(res);
		int campi = PQnfields(res);

		// stampa delle intestazioni
		for(int i = 0; i < campi; ++i)
			cout << PQfname(res,i) << "\t\t";

		cout << endl;
		cout << endl;

		// stampo i valori selezionati
		for(int i=0; i < tuple; ++i){
			// stampa singola tupla
			for(int j=0; j < campi; ++j)
				cout << PQgetvalue(res, i, j) << "\t\t";
			cout << endl;
		}

		PQclear(res);
	}

	cout << "\nComplete" << endl ;
	PQfinish ( conn );
	return 0;
	
}