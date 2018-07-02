module source.rivalgui.util.ledcolor;

// 
// Gtk
// 
import std.algorithm.comparison : max;

class LedColor
{
    public double r = 0;
    public double g = 0;
    public double b = 0;
    public double a = 0;

    this(int r, int b, int g)
    {
        setColor(r, b, g);
    }

    this(double r, double b, double g)
    {
        setColor(r, b, g);
    }

    void setColor(int r, int b, int g)
    {
        this.r = r / 255.0;
        this.b = b / 255.0;
        this.g = g / 255.0;
        transform();
    }

    void setColor(double r, double b, double g)
    {
        this.r = r;
        this.b = b;
        this.g = g;
        transform();
    }

    double getR()
    {
        return r;
    }

    double getG()
    {
        return g;
    }

    double getB()
    {
        return b;
    }

    double getA()
    {
        return a;
    }

    private void transform()
    {
        a = max(r, g, b);
        double scale;

        FIND: foreach(val; [r, g, b])
        {
            if(a == val)
            {
                scale = 1 / val;
                break FIND;
            }
        }

        r *= scale;
        g *= scale;
        b *= scale;
    }

}