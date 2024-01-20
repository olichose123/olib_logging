package olib.logging.tests;

import olib.logging.Logger.LogLevel;
import olib.logging.Logger.LogLevel;
import olib.logging.Logger;

class Main
{
    public static function main()
    {
        var logger = new Logger(Debug);
        trace("hello world");
        trace("hello world again", LogLevel.Debug);
        trace("hello world again", LogLevel.Info);

        var logger2 = new Logger(Debug, "__level__ :: __message__");
        logger2.init();
        trace("hello world");
        trace("hello world again", LogLevel.Debug);
        trace("hello world again", LogLevel.Info);

        logger.init();
        trace("hello world");
        trace("hello world again", LogLevel.Debug);
        trace("hello world again", LogLevel.Info);
    }
}
