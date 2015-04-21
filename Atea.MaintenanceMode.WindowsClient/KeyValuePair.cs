/*
 * Created by SharpDevelop.
 * User: SAPER
 * Date: 2013-02-12
 * Time: 12:47
 */
using System;

namespace Atea_Request_Maintenance_Mode
{
	/// <summary>
	/// Provides a Key-Value object for Combo Boxes
	/// </summary>
	/// 
	
	public class KeyValuePair
	{
		public object m_objectKey;
		public string m_stringValue;
		
		public KeyValuePair(object NewKey, string NewValue)
		{
			m_objectKey = NewKey;
			m_stringValue = NewValue;
		}
		
		public override string ToString()
		{
			return m_stringValue;
		}

	}
}
