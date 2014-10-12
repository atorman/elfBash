public class vfRequestTimeController {

public vfRequestTimeController() {}
    
  List<Task> tasks;

  public List<Task> getTasks() {
    tasks = [SELECT Subject, CreatedDate FROM Task ORDER BY CreatedDate DESC limit 2];
    return tasks; 
  }

@RemoteAction
    public static String createTask(string Subject) {
       Task t = new Task(Subject=Subject);
       insert t;
       //System.debug('Task Id: ' + t.Id + ' Task Subject: ' + t.Subject);
       return t.Id;  
    }

}