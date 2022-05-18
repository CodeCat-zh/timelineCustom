
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
namespace Cutscene
{
    public class ClipParam
    {
        public string fieldName;
        public string value;

        public ClipParam(string fieldName, string value)
        {
            this.fieldName = fieldName;
            this.value = value;
        }
    }

}