/*
	Per compilare:
							g++ codice.cpp -L dependencies\lib -lpq -o codice
*/

#include <cstdio>
#include <iostream>
#include <fstream>
#include "dependencies/include/libpq-fe.h"

using namespace std;

#define PG_HOST 	"127.0.0.1"
#define PG_USER 	"postgres"
#define PG_DB 		"delivery"
#define PG_PASS 	"admin$23"
#define PG_PORT		5432

// Funzione per controllare i risultati della Query
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

		for(int i=0; i < 3; i++){

			string query = "INSERT INTO hubs (hub, country) VALUES ($1, $2)";

			PGresult *stmt = PQprepare(conn, "query", query.c_str(), 2, NULL);

			string hub, country;

			cout << "Inserire il nome del " << i+1 << " hub: ";
			cin >> hub;
			cout << "Inserire codice paese di origine: ";
			cin >> country;

			const char* parameter[2];

			parameter[0] = hub.c_str();
			parameter[1] = country.c_str();

			PGresult *res = PQexecPrepared(conn, "query", 2, parameter, NULL, 0, 0);

			cout << PQresultErrorMessage(res);

			PQclear(res);
			PQclear(stmt);
		}
	}

	cout << "\nComplete" << endl ;
	PQfinish ( conn );
	return 0;
	
}