using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using LuaInterface;
#if UNITY_EDITOR
using Xceed.Words.NET;
using UnityEditor;
#endif
using System.Text.RegularExpressions;
using UnityEngine;

namespace PJBN.Cutscene
{
	public class CutsceneDocxReader
	{
		private static readonly Regex[] s_EventRegex_Chapter = new Regex[]
		{
			new Regex("节点.+：（(.+)）", RegexOptions.Singleline),
			new Regex("节点.+:（(.+)）", RegexOptions.Singleline)
		};

		private static readonly Regex[] s_EventRegex_Dialogue = new Regex[]
		{
			new Regex("(^[\u4e00-\u9fa5A-Za-z0-9_？]+)：(.+)", RegexOptions.Singleline),
			new Regex("(^[\u4e00-\u9fa5A-Za-z0-9_？]+):(.+)", RegexOptions.Singleline)
		};

		private static readonly Regex[] s_EventRegex_Dialogue_With_Emoji = new Regex[]
		{
			new Regex("(^[\u4e00-\u9fa5A-Za-z0-9_？]+)（(.*)）：(.+)", RegexOptions.Singleline),
			new Regex("(^[\u4e00-\u9fa5A-Za-z0-9_？]+)（(.*)）:(.+)", RegexOptions.Singleline)
		};

		public static void ImportDocxFile(LuaFunction callback)
		{
#if UNITY_EDITOR
			string path = EditorUtility.OpenFilePanel("", "", "");
			if (string.IsNullOrEmpty(path))
			{
				EditorUtility.DisplayDialog("", "路径不能为空!", "确定");
				return;
			}

			try
			{
				Dictionary<string, CutsceneDocxData> cutsceneWordses = new Dictionary<string, CutsceneDocxData>();

				CutsceneDocxData temp = null;
				CutsceneDocxChat chatTemp = null;
				string cutsceneFileName = "";

				using (var document = DocX.Load(path))
				{
					foreach (var item in document.Paragraphs)
					{
						bool isChapter = false;
						bool isMatch = false;
						
						for (int i = 0; i < s_EventRegex_Chapter.Length; i++)
						{
							foreach (Match match in s_EventRegex_Chapter[i].Matches(item.Text))
							{
								if (chatTemp != null)
								{
									if (chatTemp.DialogueCount > 0)
									{
										temp.AddChat(chatTemp);
									}

									chatTemp = null;
								}
								cutsceneFileName = match.Groups[1].ToString();
								if (!cutsceneWordses.ContainsKey(cutsceneFileName))
								{
									CutsceneDocxData toAddCutsWords = new CutsceneDocxData();
									toAddCutsWords.FileName = cutsceneFileName;
									cutsceneWordses.Add(cutsceneFileName, toAddCutsWords);
								}

								isChapter = true;
								temp = cutsceneWordses[cutsceneFileName];
								isMatch = true;
								break;
							}

							if (isMatch)
							{
								break;
							}
						}
						

						if (isChapter || (temp == null))
						{
							continue;
						}

						if (item.MagicText.Count == 0)
						{
							continue;
						}

						bool isBold = false;

						if (item.MagicText[0].formatting != null && item.MagicText[0].formatting.Bold.HasValue)
						{
							if (item.MagicText[0].formatting.Bold.Equals(true))
							{
								if (chatTemp != null && (chatTemp.DialogueCount > 0))
								{
									temp.AddChat(chatTemp);
									chatTemp = null;
								}

								if (chatTemp == null)
								{
									chatTemp = new CutsceneDocxChat();
									chatTemp.ChatId = temp.ChatId++;
								}

								for (int i = 0; i < s_EventRegex_Dialogue.Length; i++)
								{
									isMatch = false;
									foreach (Match match in s_EventRegex_Dialogue[i].Matches(item.Text))
									{
										var dialogue = match.Groups[2].ToString().TrimEnd();
										if (!string.IsNullOrEmpty(dialogue))
										{
											temp.AddNormalContent(dialogue);
										}

										isMatch = true;
									}

									if (isMatch)
									{
										break;
									}
								}

								
								isBold = true;
							}
						}

						if (isBold || chatTemp == null)
						{
							continue;
						}

						bool existEmoji = false;
						
						for (int i = 0; i < s_EventRegex_Dialogue_With_Emoji.Length; i++)
						{
							isMatch = false;
							foreach (Match match in s_EventRegex_Dialogue_With_Emoji[i].Matches(item.Text))
							{
								var dialogue = match.Groups[3].ToString().TrimEnd();
								if (!string.IsNullOrEmpty(dialogue))
								{
									chatTemp.AddDialogue(match.Groups[1].ToString(), match.Groups[2].ToString(),
										match.Groups[3].ToString());
								}

								existEmoji = true;
								isMatch = true;
							}

							if (isMatch)
							{
								break;
							}
						}

						if (existEmoji)
						{
							continue;
						}

						for (int i = 0; i < s_EventRegex_Dialogue.Length; i++)
						{
							isMatch = false;
							foreach (Match match in s_EventRegex_Dialogue[i].Matches(item.Text))
							{
								var dialogue = match.Groups[2].ToString().TrimEnd();
								if (!string.IsNullOrEmpty(dialogue))
								{
									chatTemp.AddDialogue(match.Groups[1].ToString(), "null",
										match.Groups[2].ToString());
								}

								isMatch = true;
							}

							if (isMatch)
							{
								break;
							}
						}

						if (!isMatch)
						{
							if (chatTemp != null)
							{
								if (chatTemp.DialogueCount > 0)
								{
									temp.AddChat(chatTemp);
								}

								chatTemp = null;
							}
						}
					}

					if (callback != null)
					{
						callback.Call(cutsceneWordses.Values.ToArray());
					}
				}
			}
			catch (Exception e)
			{
				if (e is IOException)
				{
					EditorUtility.DisplayDialog("", "请先关掉打开的文档!", "确定");
				}
				else
				{
					Debug.LogError(e.ToString());
				}
			}
		#endif
		}

	}

	public class CutsceneDocxData
	{
		public int ChatId = 201000;
		public string FileName;
		private List<string> _normalContents = new List<string>();
		private List<CutsceneDocxChat> _chats = new List<CutsceneDocxChat>();

		public CutsceneDocxChat[] GetChatArray()
		{
			return _chats.ToArray();
		}

		public string[] GetNormalContentArray()
		{
			return _normalContents.ToArray();
		}

		public CutsceneDocxDialogue[] GetActorDialogueList(string actorName)
		{
			List<CutsceneDocxDialogue> list = new List<CutsceneDocxDialogue>();
			for (int i = 0; i < _chats.Count; i++)
			{
				int count = _chats[i].DialogueCount;
				for (int j = 0; j < count; j++)
				{
					CutsceneDocxDialogue dialogue = _chats[i].GetDialogue(j);
					if (dialogue.actorName == actorName)
					{
						list.Add(dialogue);
					}
				}
			}
			return list.ToArray();
		}

		public void AddChat(CutsceneDocxChat chat)
		{
			_chats.Add(chat);
		}

		public void AddNormalContent(string content)
		{
			_normalContents.Add(content);
		}

		public void Print()
		{
			Debug.LogFormat("===================={0}=================", FileName);
			Debug.LogFormat("=================Content count==={0}=================", _normalContents.Count);
			Debug.Log(string.Join("\n", _normalContents.ToArray()));
			Debug.LogFormat("=================Chat count==={0}=================", _chats.Count);
			for (int i = 0; i < _chats.Count; i++)
			{
				_chats[i].Print();
			}
		}
	}

	public class CutsceneDocxDialogue
	{
		public int id;
		public string actorName;
		public string emojiName;
		public string content;
		public void Print()
		{
			Debug.LogFormat("=================Dialogue ID==={0}=================", id);
			Debug.LogFormat("{0}({1}):{2}", actorName, emojiName, content);
		}
	}

	public class CutsceneDocxChat
	{
		private int _chatId;
		public int ChatId
		{
			set
			{
				_chatId = value;
				_dialogueId = _chatId * 10;
			}
			get { return _chatId; }
		}

		private int _dialogueId;

		public int DialogueId
		{
			get { return _dialogueId; }
		}

		private List<CutsceneDocxDialogue> dialogues = new List<CutsceneDocxDialogue>();

		public int DialogueCount
		{
			get { return dialogues.Count; }
		}

		public CutsceneDocxDialogue GetDialogue(int index)
		{
			if (dialogues.Count > index)
			{
				return dialogues[index];
			}

			return null;
		}

		public void AddDialogue(string actorName, string emojiName, string content)
		{
			CutsceneDocxDialogue dialogue = new CutsceneDocxDialogue();
			dialogue.id = _dialogueId++;
			dialogue.actorName = actorName;
			dialogue.emojiName = emojiName;
			dialogue.content = content;
			dialogues.Add(dialogue);
		}

		public void Print()
		{
			Debug.LogFormat("=================Chat ID==={0}=================", _chatId);
			Debug.LogFormat("=================Dialogue count==={0}=================", dialogues.Count);
			for (int i = 0; i < dialogues.Count; i++)
			{
				dialogues[i].Print();
			}
		}
	}
}