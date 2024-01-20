package olib.logging;

import haxe.PosInfos;

using StringTools;
using haxe.EnumTools.EnumValueTools;

class Logger
{
    static var log_level_order = [
        LogLevel.Debug => 0,
        LogLevel.Info => 1,
        LogLevel.Warning => 2,
        LogLevel.Error => 3,
        LogLevel.Critical => 4,
    ];

    static var internal_trace:(v:Dynamic, ?infos:PosInfos) -> Void;
    static var globalLogger:Logger;

    public var format:LogFormat;
    public var logLevel:LogLevel;

    public var logs:Array<String> = [];

    public function new(?level:LogLevel, ?format:LogFormat):Void
    {
        this.format = format == null ? new LogFormat() : format;
        this.logLevel = level == null ? LogLevel.Debug : level;
        if (internal_trace == null)
        {
            internal_trace = haxe.Log.trace;
            haxe.Log.trace = Logger.trace;
            init();
        }
    }

    public function init():Void
    {
        globalLogger = this;
    }

    public function log(level:LogLevel, message:String, ?infos:PosInfos):Void
    {
        if (log_level_order[level] < log_level_order[logLevel])
        {
            return;
        }
        var msg = format.format(level, message);
        logs.push(msg);
        print(msg);
    }

    static function trace(v:Dynamic, ?infos:PosInfos):Void
    {
        if (globalLogger != null)
        {
            var last_param = infos.customParams?.pop();
            var current_log_level = log_level_order[globalLogger.logLevel];
            if (last_param != null && Std.isOfType(last_param, LogLevel))
            {
                switch (last_param)
                {
                    case LogLevel.Debug:
                        if (current_log_level > 0)
                        {
                            return;
                        }
                    case LogLevel.Info:
                        if (current_log_level > 1)
                        {
                            return;
                        }
                    case LogLevel.Warning:
                        if (current_log_level > 2)
                        {
                            return;
                        }
                    case LogLevel.Error:
                        if (current_log_level > 3)
                        {
                            return;
                        }
                    case LogLevel.Critical:
                        if (current_log_level <= 4)
                        {
                            return;
                        }
                }
                globalLogger.log(last_param, v.toString(), infos);
                return;
            }

            globalLogger.log(LogLevel.Debug, v.toString(), infos);
        }
        else
        {
            print(v);
        }
    }

    static function print(message:Dynamic):Void
    {
        #if js
        if (js.Syntax.typeof(untyped console) != "undefined" && (untyped console).log != null)
            (untyped console).log(message);
        #elseif lua
        untyped __define_feature__("use._hx_print", _hx_print(message));
        #elseif sys
        Sys.println(Std.string(message));
        #else
        throw new haxe.exceptions.NotImplementedException();
        #end
    }
}

abstract LogFormat(String) from String to String
{
    public static final date = "__date__";
    public static final level = "__level__";
    public static final message = "__message__";

    public inline function new(?s:String)
    {
        this = s == null ? "[__level__] __date__ __message__" : s;
    }

    public function format(msg_level:LogLevel, msg:String):String
    {
        var s = this;
        s = s.replace(date, Date.now().toString());
        s = s.replace(level, msg_level.getName());
        s = s.replace(message, msg);
        return s;
    }
}

enum LogLevel
{
    Debug;
    Info;
    Warning;
    Error;
    Critical;
}
