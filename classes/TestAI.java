import java.util.Scanner;

public class TestAI
{
    static Scanner in = new Scanner(System.in);

    public static void main(String [] args)
    {
        while(true)
        {
            //turnLeft();
            //thrust();
            //shoot();
            //scan(0, Math.PI/4);
            double scans = 64;
            double offset = 2 * Math.PI / scans;
            int i = 0;
            while(true)
            {
                double angle = i * offset;
                if(scan(angle, offset) >= 0)
                    shoot(angle);
                else
                    i++;
            }
            //double pos[] = getPosition();
            //System.err.println(pos[0] + ":" + pos[1]);
            //System.err.println(getAngle());
        }
    }

    protected static void shoot(double angle)
    {
        System.out.println("shoot " + angle);
    }

    protected static void turnRight()
    {
        System.out.println("right");
    }

    protected static void turnLeft()
    {
        System.out.println("left");
    }

    protected static void thrust()
    {
        System.out.println("thrust");
    }

    protected static double[] getPosition()
    {
        System.out.println("get_pos");
        double ret[] = new double[2];
        ret[0] = in.nextDouble();
        ret[1] = in.nextDouble();
        in.nextLine();
        return ret;
    }

    protected static double getAngle()
    {
        System.out.println("get_angle");
        double ret = in.nextDouble();
        in.nextLine();
        return ret;
    }

    protected static double scan(double angle, double span)
    {
        System.out.println("scan " + angle + " " + span);
        double ret = in.nextDouble();
        in.nextLine();
        return ret;
    }
}
