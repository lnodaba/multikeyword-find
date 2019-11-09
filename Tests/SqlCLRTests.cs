using System;
using System.Collections.Generic;
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

        [TestMethod]
        public void udf_TagFilter_QuarterCalls_CLR_Test()
        {
            SqlString Paragraph = "N2/4S2E4, SWSE, NESW, SE LOT 1, 3, 5 LOT 4 LOT 6,7";

            var result = UserDefinedFunctions.udf_TagFilter_QuarterCalls_CLR(Paragraph);
            var resultList = new List<string>();
            foreach (var item in result)
            {
                resultList.Add(item.ToString());
            }

            Assert.IsTrue(resultList.Count == 7);
        }
    }
}
