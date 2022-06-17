namespace Polaris.CutsceneEditor
{
    public class ModelSelectInfo
    {
        public string key { set; get; }
        public string id { set; get; }
        public string modelId { set; get; }
        public string name { set; get; }

        public ModelSelectInfo(string keyValue, string idValue,string modelIdValue,string nameValue)
        {
            key = keyValue;
            id = idValue;
            modelId = modelIdValue;
            name = nameValue;
        }
    }
}