using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using System.Text.RegularExpressions;
using Microsoft.SqlServer.Server;

public partial class UserDefinedFunctions
{
    

    [SqlFunction(FillRowMethodName = "FillRow",TableDefinition = "Phrases NVARCHAR(MAX)")]
    public static IEnumerable udf_TagFilter_QuarterCalls_CLR(SqlString Paragraph)
    {
        string RegExp = GetQuarterCallsRegex();
        
        string[] result = GetQuarterCallPhrases(Paragraph.Value, RegExp);

        return result;
    }

    private static string[] GetQuarterCallPhrases(string Paragraph, string RegExp)
    {
        List<string> result = new List<string>();

        Regex regex = new Regex(RegExp, RegexOptions.IgnoreCase);
        foreach (var phrase in regex.Matches(Paragraph))
        {
            result.Add(phrase.ToString());
        }

        return result.ToArray() ;
    }

    private static string GetQuarterCallsRegex()
    {
        string cardinalDirection = "[NESW]{1}",
            numberOrFraction = @"(\d?)(\/?)(\d?)",
            lot = "(LOT)",
            commaSeparatedNumbers = @"(\s?)(\d?)(\s?)(,?)";

        return $@"(\b({cardinalDirection}{numberOrFraction}){{2,4}}\b)|" //2 to 4 times
        + $@"(\b{lot}({commaSeparatedNumbers})+)"; 
    }
    public static void FillRow(Object obj, out SqlString result)
    {
        result = (obj as string);
    }

}
