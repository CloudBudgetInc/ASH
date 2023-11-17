global class MultiSelectFlowValues {
   
   @InvocableMethod
   public static List<list<string>> CheckValues(List<string> values) {

      if(!(values.isEmpty())){
         List<list<string>> finalLst = new list<list<string>>();

         for (String tStr : values) {
             List<String> lstnew = tStr.split(';');

             finalLst.add(lstnew);
         }

         return finalLst;
      }

      else return null;
   }
}