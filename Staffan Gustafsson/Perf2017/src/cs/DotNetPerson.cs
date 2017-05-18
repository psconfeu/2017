using System;
using System.Management.Automation;
namespace DotNet
{
    public class Person
    {
        public Person() { }
        public Person(string name, int age)
        {
            Name = name;
            Age = age;
        }
        public string Name { get; set; }
        public int Age { get; set; }

        public override string ToString()
        {
            return Name;
        }
    }

    public static class CodeMethods
    {
        public static DateTime AddFortnight(PSObject o)
        {
            if (o.BaseObject is DateTime d)
            {
                return d.AddDays(14);
            }
            throw new ArgumentException("object not a datetime");
        }
    }

    public class SimpleMath
    {
        public static long Add(int i, int j) => i + j;
    }
}