using System;
using System.Collections.Generic;
using System.Data.SqlTypes;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ConsoleApp
{
    class Program
    {
        static void Main(string[] args)
        {
            SqlString Paragraph = "word1 test inbetween test test five word2 word1 test inbetween should return word2 separator word1 inbetween test should return word2";
            SqlString KeyWords = "word1,test,inbetween,word2";
            SqlInt16 MaxWordCountBeetween = 4;
            SqlBoolean MaintainOrder = true;

            var result = UserDefinedFunctions.MultiKeywordFind(Paragraph, KeyWords, MaxWordCountBeetween, MaintainOrder);
            var checkResultHere = result;
        }
    }
}