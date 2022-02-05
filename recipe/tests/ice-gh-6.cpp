/* File test.cpp */
int rand();

template<typename T>
struct s
{
    int count() { return rand(); }
};

template<typename v>
int f(s<v> a)
{
    int const x = a.count();
    int r = 0;
    auto l = [&](int& r)
    {
        for(int y = 0, yend = (x); y < yend; ++y)
        {
            r += y;
        }
    };
    l(r);
}

template int f(s<float>);

int main()
{
}
