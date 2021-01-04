#include<iostream>
#include "BST.h"

using namespace std;
using namespace BST;

int main() {
    //prepara un albero iniziale non triviale
    nodo *r = new nodo(15, new nodo(7), new nodo(19));
    r->left->right = new nodo(9, new nodo(8));
    r->right->right = new nodo(25, new nodo(22));


    cout << "Dim. albero: ";
    int dim;
    cin >> dim;
    int *a = new int[dim];
    for (int i = 0; i < dim; i++)
        cin >> a[i];

    nodo *root;
    root = buildTree(a, 0, dim);
    stampa_l(root);
    cout << endl;

    bool stop = false;
    while (!stop) {
        //legge le istruzoni e le esegue
        cout << "Menu" << endl;
        cout << "1  - Stampa albero BST" << endl;
        cout << "2  - Insert su albero BST" << endl;
        cout << "3  - Search su albero BST" << endl;
        cout << "4  - Max BST (1) e Min BST (2)" << endl;
        cout << "5  - Altezza 1" << endl;
        cout << "6  - Altezza MINIMA" << endl;
        cout << "7  - Elim BST" << endl;
        cout << "8  - Altezza 1 e 2" << endl;
        cout << "9  - Stampa Breath-First Iterativa + Ricorsiva" << endl;
        cout << "10 - Search Iterativa BST" << endl;
        cout << "11 - Insert con passaggio per riferimento" << endl;
        int x;
        cout << "Scelta: ";
        cin >> x;
        int val;
        switch (x) {
            case 1:
                stampa_l(r);
                break;
            case 2:
                cin >> val;
                r = insert(r, val);
                stampa_l(r);
                break;
            case 3:
                cin >> val;
                if (search(r, val))
                    cout << "valore " << val << " presente";
                else
                    cout << "valore " << val << " non presente";
                break;
            case 4:
                cin >> val;
                if (val == 1) cout << max(r)->info;
                if (val == 2) cout << min(r)->info;
                break;
            case 5:
                cout << altezza(r);
                break;
            case 6:
                cout << altMin(r);
                break;
            case 7:
                cin >> val;
                elim(r, val);
                stampa_l(r);
                break;
            case 8:
                cout << "Altezza 2: " << altezza2(root) << " " << altezza2(r) << endl;
                cout << "Altezza 1: " << altezza(root) << " " << altezza(r);
                break;
            case 9:
                cout << "Stampa Breath-First: " << endl;
                breathFirst(root);
                cout << endl;
                cout << "Stampa Breath-First ricorsiva: " << endl;
                breathFirstRIC(root);
                break;
            case 10:
                cin >> val;
                if (searchIte(r, val))
                    cout << "valore " << val << " presente";
                else
                    cout << "valore " << val << " non presente";
                break;
            case 11:
                cin >> val;
                insert3(r, val);
                stampa_l(r);
                break;
            default:
                stop = true;
        }
        cout << endl;
    }
}