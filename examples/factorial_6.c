fun factorial (int n) : (int)
{
    if (n == 0) {
        return 1;
    } else {
        n = n * factorial(n - 1);
        return n;
    }
}

fun main () : int
{
    int a = 6;

    a = factorial(a);

    return a;
}
