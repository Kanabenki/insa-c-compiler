
// globals cannot be assigned at global scope
int global1;
int global2;

main() {
    global1 = 3;
    global2 = 5;
    int local1 = 2 + global1;
    while (global1 < 30) {
        global1 = local1 + global1;
    }
    if (global2 | local1  & 7) {
        int local3 = 8;
    } else {
        {
            int local4 = (global1 + local1) * global2 | 3;
        }
    }

    
}