using System;

public enum PlayableFieldEnum
{
    GameObejct,
    Enum,
    Bool,
    Int,
    Float,
    String,
    Vector3,
    Color
}
[AttributeUsage(AttributeTargets.Field)]
public class FieldConvertToString : Attribute
{
    private PlayableFieldEnum fieldEnum;
    public FieldConvertToString(PlayableFieldEnum playableFieldEnum)
    {
        fieldEnum = playableFieldEnum;
    }

    public PlayableFieldEnum FieldEnum { get => fieldEnum; set => fieldEnum = value; }
}
