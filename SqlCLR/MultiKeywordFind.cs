using System;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using Microsoft.SqlServer.Server;
using System.Collections;
using System.Collections.Generic;
using System.Text.RegularExpressions;

public partial class UserDefinedFunctions
{
    /// <summary>
    /// The Arguments wrapped into a Domain Object
    /// </summary>
    private class FindSettings
    {

        public string First { get; }
        public string Last { get; }
        public List<string> InBetweenWords { get; }
        public int MaxWordCountBeetween { get; }
        public bool MaintainOrder { get; }

        public FindSettings(string KeyWords, int MaxWordCountBeetween, bool MaintainOrder)
        {
            List<string> keywords = new List<string>(KeyWords.Split(','));
            this.First = keywords[0]; //get first
            this.Last = keywords[keywords.Count - 1]; //get last
            keywords.RemoveAt(0);
            keywords.RemoveAt(keywords.Count - 1);

            this.InBetweenWords = keywords;
            this.MaxWordCountBeetween = MaxWordCountBeetween;
            this.MaintainOrder = MaintainOrder;
        }

        /// <summary>
        /// Generates a RegEx for Finding the Phrases it also counts the distance between the words.
        /// So it is using the MaxWordCountBeetween parameter.
        /// </summary>
        public string RegexForFirstAndLast
        {
            get => $@"({First})\W+(\w+\W+){{0,{MaxWordCountBeetween}}}?({Last})"; 
        }
    }

    [Microsoft.SqlServer.Server.SqlFunction(TableDefinition = "Phrases NVARCHAR(MAX)")]
    public static IEnumerable MultiKeywordFind(SqlString Paragraph,SqlString KeyWords,SqlInt16 MaxWordCountBeetween,SqlBoolean MaintainOrder)
    {
        var settings = new FindSettings(KeyWords.Value, MaxWordCountBeetween.Value, MaintainOrder.Value);

        List<string> result = getPhrases(Paragraph, settings);

        return result;
    }

    private static List<string> getPhrases(SqlString Paragraph,FindSettings settings)
    {
        List<string> result = new List<string>();

        Regex regex = new Regex(settings.RegexForFirstAndLast, RegexOptions.IgnoreCase);
        foreach (var phrase in regex.Matches(Paragraph.Value))
        {
            if (containsAllWords(phrase.ToString(), settings.InBetweenWords,settings.MaintainOrder))
            {
                result.Add(phrase.ToString());
            }
        }

        return result;
    }

    private static bool containsAllWords(string phrase, List<string> inBetweenWords, bool maintainOrder)
    {
        if (inBetweenWords.Count == 0)
            return true;
        
        int lastIndex = 0;
        foreach (var word in inBetweenWords)
        {
            int index = phrase.IndexOf(word);

            if (index < 0)
                return false;
            if (maintainOrder && lastIndex > index)
                return false;

            lastIndex = index;
        }

        return true;
    }
}
