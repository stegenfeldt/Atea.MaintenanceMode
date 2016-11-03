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
    /// Helper class to manage Key-Value pairs for the drop-down menues.
    /// </summary>
	public class KeyValuePair
    {

        /// <summary>
        /// Key object in the key-value pair
        /// </summary>
        public object m_objectKey;

        /// <summary>
        /// String value in the key-value pair
        /// </summary>
		public string m_stringValue;

        /// <summary>
        /// Simple constructor to add Key-Value pairs to class instances.
        /// </summary>
        /// <param name="NewKey"></param>
        /// <param name="NewValue"></param>
        public KeyValuePair(object NewKey, string NewValue)
        {
            m_objectKey = NewKey;
            m_stringValue = NewValue;
        }

        /// <summary>
        /// Convert and return the string value from the object
        /// </summary>
        /// <returns>String value from the Key-Value pair</returns>
        public override string ToString()
        {
            return m_stringValue;
        }

    }
}
