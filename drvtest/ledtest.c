void main(void)
{
    system("echo 1 > /sys/class/leds/led1/brightness");
    system("echo 1 > /sys/class/leds/led2/brightness");
    system("echo 1 > /sys/class/leds/led3/brightness");
    system("echo 1 > /sys/class/leds/led4/brightness");
    usleep(1000000);

    system("echo 0 > /sys/class/leds/led1/brightness");
    system("echo 0 > /sys/class/leds/led2/brightness");
    system("echo 0 > /sys/class/leds/led3/brightness");
    system("echo 0 > /sys/class/leds/led4/brightness");
    usleep(1000000);

    while (1)
    {
        system("echo 0 > /sys/class/leds/led1/brightness");
        system("echo 1 > /sys/class/leds/led2/brightness"); usleep(200000);

        system("echo 0 > /sys/class/leds/led2/brightness");
        system("echo 1 > /sys/class/leds/led3/brightness"); usleep(200000);

        system("echo 0 > /sys/class/leds/led3/brightness");
        system("echo 1 > /sys/class/leds/led4/brightness"); usleep(200000);

        system("echo 0 > /sys/class/leds/led4/brightness");
        system("echo 1 > /sys/class/leds/led1/brightness"); usleep(200000);
    }
}
