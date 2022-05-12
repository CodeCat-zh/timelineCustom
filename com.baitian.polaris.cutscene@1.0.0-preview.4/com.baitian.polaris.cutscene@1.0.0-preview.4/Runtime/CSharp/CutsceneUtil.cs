
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using LuaInterface;
using UnityEngine;
using UnityEngine.UI;

namespace Polaris.Cutscene
{
	public static class CutsceneUtil
	{
		public static void CopyTextComponenetValues(Text target, Text origin)
		{
			if (!target || !origin)
			{
				return;
			}

			target.text = origin.text;
			target.alignment = origin.alignment;
			target.font = origin.font;
			target.fontSize = origin.fontSize;
			target.fontStyle = origin.fontStyle;
			target.color = origin.color;
			target.supportRichText = origin.supportRichText;
			target.horizontalOverflow = origin.horizontalOverflow;
			target.verticalOverflow = origin.verticalOverflow;
			target.lineSpacing = origin.lineSpacing;
		}

		private class TextItem
		{
			public string text;
			public bool isTag;
		}

		private static List<TextItem> textList = new List<TextItem>();
		private static StringBuilder sb;
		private static Regex _regex = new Regex("([A-Za-z0-9_]+$)", RegexOptions.Singleline);

		/// <summary>
		/// 海外版添加功能,国内没有该接口
		/// </summary>
		/// <param name="textComponent"></param>
		/// <param name="content"></param>
		/// <returns></returns>
		public static string[] SplitContentToFitTextComponent(Text textComponent, string content)
		{
			textList.Clear();
			List<string> result = new List<string>();
			TextGenerator textGenerator = new TextGenerator();
			RectTransform rt = textComponent.GetComponent<RectTransform>();
			textComponent.horizontalOverflow = HorizontalWrapMode.Overflow;
			TextGenerationSettings textGenerationSettings = textComponent.GetGenerationSettings(rt.sizeDelta);
			textComponent.horizontalOverflow = HorizontalWrapMode.Wrap;
			textGenerationSettings.scaleFactor = 1.0f;
			sb = new StringBuilder();
			while (true)
			{
				string next = PickOneTag(content);
				if (next == content)
				{
					if (!string.IsNullOrEmpty(content))
					{
						TextItem item = new TextItem();
						item.text = content;
						item.isTag = false;
						textList.Add(item);
					}
					break;
				}
				content = next;
			}

			int currentIndex = 0;
			int currentListIndex = 0;
			int startListIndex = 0;
			int startIndex = 0;
			string subContent = "";
			string subLine = "";
			string output = "";
			float maxWidth = rt.sizeDelta.x;
			float maxHeight = rt.sizeDelta.y;
			float currenLineWidth = 0;
			float currentContentHeight = 0;
			bool isEndWithLF = false;

			while (true)
			{
				if (textList[currentListIndex].isTag || currentIndex == textList[currentListIndex].text.Length)
				{
					currentIndex = 0;
					currentListIndex++;

					while (currentListIndex < textList.Count && textList[currentListIndex].isTag)
					{
						currentListIndex++;
					}

					if (currentListIndex == textList.Count)
					{//遍历结束
						if (!string.IsNullOrEmpty(subLine))
						{
							if (string.IsNullOrEmpty(subContent))
							{
								result.Add(subLine);
							}
							else
							{
								output = subContent + ("\n") + subLine;
								float height = textGenerator.GetPreferredHeight(output, textGenerationSettings);
								if (height > maxHeight)
								{
									result.Add(subContent);
									result.Add(subLine);
								}
								else
								{
									result.Add(output);
								}
							}
						}
						else if (!string.IsNullOrEmpty(subContent))
						{
							result.Add(subContent);
						}
						break;
					}
				}
				else
				{
					subLine = GetText(startListIndex, currentListIndex, startIndex, currentIndex, out isEndWithLF);
					currenLineWidth = textGenerator.GetPreferredWidth(subLine, textGenerationSettings);
					if (currenLineWidth > maxWidth)
					{//太长换行
						int lattersLength = GetLastLattersLength(startListIndex, currentListIndex, startIndex, currentIndex);
						int subLineRealIndex = currentIndex - lattersLength;
						subLine = GetText(startListIndex, currentListIndex, startIndex, subLineRealIndex, out isEndWithLF);
						startListIndex = currentListIndex;
						startIndex = currentIndex - lattersLength + 1;
						output = subContent + (string.IsNullOrEmpty(subContent) ? "" : "\n") + subLine;
						currentContentHeight = textGenerator.GetPreferredHeight(output, textGenerationSettings);
						if (currentContentHeight > maxHeight)
						{//添加当前行会导致高度超过,将当前段内容添加到列表中,开始计算新的一段,新的段起始值为当前行,重新计算当前行
							result.Add(subContent);
							subContent = subLine;
						}
						else
						{//将当前行添加到当前段中
							subContent = output;
						}
						subLine = GetText(startListIndex, currentListIndex, startIndex, currentIndex, out isEndWithLF);
					}
					else if (isEndWithLF)
					{
						output = subContent + (string.IsNullOrEmpty(subContent) ? "" : "\n") + subLine;
						currentContentHeight = textGenerator.GetPreferredHeight(output, textGenerationSettings);
						if (currentContentHeight > maxHeight)
						{
							subLine = GetText(startListIndex, currentListIndex, startIndex, currentIndex - 1,
								out isEndWithLF);
							output = subContent + (string.IsNullOrEmpty(subContent) ? "" : "\n") + subLine;
							result.Add(output);//旧的一段结尾去掉换行符
							subContent = "";
							startIndex = currentIndex + 1;//新的一段的起点跳过换行符
							startListIndex = currentListIndex;
							subLine = "";
						}
					}
					currentIndex++;
				}
			}

			sb.Length = 0;
			sb = null;
			textList.Clear();
			return result.ToArray();
		}


		static int GetLastLattersLength(int startListIndex, int currentListIndex, int startIndexInStartList, int currentIndex)
		{
			sb.Length = 0;

			if (currentListIndex != startListIndex)
			{
				string cur = textList[startListIndex].text;
				sb.Append(cur.Substring(startIndexInStartList));

				for (int i = startListIndex + 1; i < currentListIndex; i++)
				{
					sb.Append(textList[i].text);
				}
				cur = textList[currentListIndex].text;
				sb.Append(cur.Substring(0, currentIndex + 1));
			}
			else
			{
				string cur = textList[currentListIndex].text;
				sb.Append(cur.Substring(startIndexInStartList, currentIndex - startIndexInStartList + 1));
			}

			string content = sb.ToString();

			foreach (Match match in _regex.Matches(content))
			{
				return match.Groups[1].Length;
			}

			return 1;
		}

		static string GetText(int startListIndex, int currentListIndex, int startIndexInStartList, int currentIndex, out bool endWithLF)
		{
			sb.Length = 0;

			for (int i = 0; i < startListIndex; i++)
			{
				TextItem item = textList[i];
				if (item.isTag)
					sb.Append(item.text);
			}

			if (currentListIndex != startListIndex)
			{
				string cur = textList[startListIndex].text;
				sb.Append(cur.Substring(startIndexInStartList));

				for (int i = startListIndex + 1; i < currentListIndex; i++)
				{
					sb.Append(textList[i].text);
				}
				cur = textList[currentListIndex].text;
				sb.Append(cur.Substring(0, currentIndex + 1));
			}
			else
			{
				string cur = textList[currentListIndex].text;
				sb.Append(cur.Substring(startIndexInStartList, currentIndex - startIndexInStartList + 1));
			}

			var content = sb.ToString();
			endWithLF = content.EndsWith("\n");

			for (int i = currentListIndex + 1; i < textList.Count; i++)
			{
				TextItem item = textList[i];
				if (item.isTag)
					sb.Append(item.text);
			}

			return sb.ToString();
		}


		private static string PickOneTag(string text)
		{
			int i = text.IndexOf('<');
			if (i < 0)
			{
				return text;
			}
			int j = text.IndexOf('>', i + 1);
			if (j < 0)
			{
				return text;
			}
			if (i > 0)
			{
				TextItem item0 = new TextItem();
				item0.text = text.Substring(0, i);
				item0.isTag = false;
				textList.Add(item0);
			}
			TextItem itemTag = new TextItem();
			itemTag.text = text.Substring(i, j - i + 1);
			itemTag.isTag = true;
			textList.Add(itemTag);
			if (j < text.Length - 1)
			{
				return text.Substring(j + 1);
			}
			return "";
		}
	}
}
