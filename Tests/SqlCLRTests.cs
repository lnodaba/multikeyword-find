using System;
using System.Data.SqlTypes;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace Tests
{
    [TestClass]
    public class SqlCLRTests
    {
        [TestMethod]
        public void GeneralDevelopmentTest()
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
