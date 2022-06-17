using System;
using UnityEngine;

namespace Polaris.CutsceneEditor
{
    public class OptimizeScrollView
    {
        private float m_RowHeight = 18f;
        private float m_ColWidth = 52f;
        private int s_RowCount = -1;
        private int s_ColCount = 1;

        private Action<Rect, int> drawCellFunc;

        private Vector2 m_ScrollPosition;


        public OptimizeScrollView(float mRowHeight,float mColWidth,int rowCount,int colCount)
        {
            this.m_RowHeight = mRowHeight;
            this.m_ColWidth = mColWidth;
            this.s_RowCount = rowCount;
            this.s_ColCount = colCount;
        }

        public void SetRowCount(int rowCount)
        {
            this.s_RowCount = rowCount;
        }

        public void SetColCount(int colCount)
        {
            this.s_ColCount = colCount;
        }

        public int GetRowCount()
        {
            return this.s_RowCount;
        }

        public int GetColCount()
        {
            return this.s_ColCount;
        }

        public OptimizeScrollView SetDrawCellFunc(Action<Rect,int> drawCellFunc)
        {
            this.drawCellFunc = drawCellFunc;
            return this;
        }

        public void Draw(Rect rect)
        {
            Rect contentRect = new Rect(0, 0, s_ColCount * m_ColWidth, s_RowCount * m_RowHeight);
            m_ScrollPosition = GUI.BeginScrollView(rect, m_ScrollPosition, contentRect);
            
            int num;
            int num2;
            GetFirstAndLastRowVisible(out num, out num2, rect.height);
            if (num2 >= 0)
            {
                int numVisibleRows = num2 - num + 1;
                IterateVisibleItems(num, numVisibleRows, contentRect.width, rect.height);
            }

            GUI.EndScrollView(true);
        }
        
          private void GetFirstAndLastRowVisible(out int firstRowVisible, out int lastRowVisible, float viewHeight)
        {
            if (s_RowCount == 0)
            {
                firstRowVisible = lastRowVisible = -1;
            }
            else
            {
                float y = m_ScrollPosition.y;
                float height = viewHeight;
                firstRowVisible = (int) Mathf.Floor(y / m_RowHeight);
                lastRowVisible = firstRowVisible + (int) Mathf.Ceil(height / m_RowHeight);
                firstRowVisible = Mathf.Max(firstRowVisible, 0);
                lastRowVisible = Mathf.Min(lastRowVisible, s_RowCount - 1);
                if (firstRowVisible >= s_RowCount && firstRowVisible > 0)
                {
                    m_ScrollPosition.y = 0f;
                    GetFirstAndLastRowVisible(out firstRowVisible, out lastRowVisible, viewHeight);
                }
            }
        }

          /// <summary>
          /// 迭代绘制可显示的项
          /// </summary>
          /// <param name="firstRow">起始行</param>
          /// <param name="numVisibleRows">总可显示行数</param>
          /// <param name="rowWidth">每行的宽度</param>
          /// <param name="viewHeight">视图高度</param>
          private void IterateVisibleItems(int firstRow, int numVisibleRows, float rowWidth, float viewHeight)
          {
              int i = 0;
              while (i < numVisibleRows)
              {
                  int index = firstRow + i;
                  Rect rowRect = new Rect(0f, (float) index * m_RowHeight, rowWidth, m_RowHeight);
                  float num3 = rowRect.y - m_ScrollPosition.y;
                  if (num3 <= viewHeight)
                  {
                      Rect colRect = new Rect(rowRect);
                      colRect.width = m_ColWidth;

                      if (drawCellFunc != null)
                      {
                          drawCellFunc(colRect, index);
                      }

                      colRect.x += colRect.width;
                  }

                  i++;
              }
          }

    }
}