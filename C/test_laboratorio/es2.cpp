/*
	Per compilare:
							g++ codice.cpp -L dependencies\lib -lpq -o codice

	il compilatore usato dai tutor è per C++ 98!!!
*/

#include <cstdio>
#include <iostream>
#include <fstream>
#include <vector>
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

void  printResults(PGresult* res , const  PGconn* conn) {
	int  tuple = PQntuples(res);
	int  campi = PQnfields(res);

	for (int i = 0; i < campi; ++i){
		cout  << PQfname(res ,i) << "\t\t";
	}
	cout  << endl;

	for(int i = 0; i < tuple; ++i){
		for (int j = 0; j < campi; ++j){
			cout  << PQgetvalue(res , i, j) << "\t\t";
		}

	cout  << endl;
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

		vector<string> hubs_name;

	    string nome;
		cout << "Inserisci nomi hub: ";
	    cin >> nome;
	    int i = 0;
	    for(; i < 10 && nome.compare("0"); i++){
	        hubs_name.push_back(nome);
	        cout << "Inserisci nomi hub: ";
	        cin >> nome;
	    }

		for(std::vector<string>::const_iterator it = hubs_name.begin(); it!=hubs_name.end(); it++) {

			string query = "SELECT distinct trip_number FROM legs WHERE origin = $1::varchar";

			PGresult *stmt = PQprepare(conn, "query", query.c_str(), 1, NULL);
			const char* parameter = (*it).c_str();
			PGresult *res = PQexecPrepared(conn, "query", 1, &parameter, NULL, 0, 0);

			checkResults(res, conn);
			cout << endl << "Trip_number per origine: " << *it << endl;
			printResults(res , conn);
			PQclear(res);
			PQclear(stmt);
		}
	}

	//auto j = 12;

	cout << "\nComplete" << endl ;
	PQfinish ( conn );
	return 0;
	
}