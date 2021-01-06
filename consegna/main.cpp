/*
    LINUX 
        - usare il comando di compilazione nella relazione
        - #include <libpq-fe.h>

    WINDOWS
        - usare il comando: g++ main.cpp -L dependencies\lib -lpq -o main
        - #include "dependencies/include/libpq-fe.h"
*/

#include <iostream>
//#include "dependencies/include/libpq-fe.h"  // Windows
#include <libpq-fe.h> // Linux
#include <stdio.h>
#include <stdlib.h>
#include <fstream>

#include "query.h"

using namespace std;

#define PG_HOST "127.0.0.1"
#define PG_USER "postgres" // il vostro nome utente
#define PG_DB "midenacasonato" // il nome del database
#define PG_PASS "admin$23" // la vostra password
#define PG_PORT 5432

void checkResults( PGresult * res , const PGconn * conn ) {
    if ( PQresultStatus ( res ) != PGRES_TUPLES_OK ) {
        cout << "Risultati inconsistenti! || " << PQerrorMessage ( conn ) << endl ;
        PQclear ( res );
        exit (1) ;
    }
}

void checkConn(PGconn* conn) {
    if( PQstatus ( conn ) != CONNECTION_OK ){
        cout << "Errore di connessione || " << PQerrorMessage ( conn ) << endl;
        PQfinish(conn);
        exit(1);
    } else {
        cout << "Connessione avvenuta correttamente " << endl << endl;
    }
}

void stampaRes(PGresult* res) {
    int tuple = PQntuples ( res ) ;
    int campi = PQnfields ( res ) ;

    cout << endl;

    for (int i = 0; i < campi; ++i)
        printf("%-30s", PQfname(res, i));
    printf("\n");
    
    cout << endl;

    for ( int i = 0; i < tuple ; ++ i ){
        for ( int j = 0; j < campi ; ++ j)
            printf("%-30s", PQgetvalue(res, i, j));
        printf("\n");
    }
}

int main() {

    char conninfo[250];
    sprintf( conninfo , " user =%s password =%s dbname =%s hostaddr =%s port =%d",
              PG_USER , PG_PASS , PG_DB , PG_HOST , PG_PORT );

    PGconn* conn = PQconnectdb(conninfo);

    checkConn(conn);

    PGresult * res ;

    bool stop = false;
    while (!stop) {
        //legge le istruzoni e le esegue
        cout << "Scegliere la query da eseguire" << endl;
        cout << "1 - Estratto conto annuale con differenza rispetto all'anno precedente di TUTTE le associazioni" << endl;
        cout << "2 - Sedi che hanno registrato il maggior numero di prenotazioni lo scorso anno e media delle prenotazioni mensili" << endl;
        cout << "3 - Sede, campo e fascia oraria con maggiore affluenza dell'associazione Polisportiva Romana" << endl;
        cout << "4 - Saldo sedi associazione CAME, dipendenti attivi e totale prenotazioni relative a ogni sede nell'anno precendente" << endl;
        cout << "5 - Campi disponibili presso tutte le sedi della Polisportiva Romana in data 20/05/2020 nella fascia oraria 13:30/21:30" << endl;
        cout << "6 - Tesserati della Polisportiva Romana con almeno 2 prenotazioni nel 2020 e indicare il campo più prenotato e il relativo numero di prenotazioni fatte su quel campo " << endl;
        cout << "0 - Esci" << endl << endl;
        int x;
        cout << "Digitare il numero: ";
        cin >> x;
        switch (x) {
            case 1:
                res = PQexec(conn , query_1().c_str());
                break;
            case 2:
                res = PQexec(conn , query_2().c_str());
                break;
            case 3:
                res = PQexec(conn , query_3().c_str());
                break;
            case 4:
                res = PQexec(conn , query_4().c_str());
                break;
            case 5:
                res = PQexec(conn , query_5().c_str());
                break;
            case 6:
                res = PQexec(conn , query_6().c_str());
                break;
            default:
                stop = true;
        }
        if (!stop) {
            checkResults(res, conn);
            stampaRes(res);
            cout << endl;
        }
    }

    PQclear(res);
    PQfinish(conn);
    return 0;
}