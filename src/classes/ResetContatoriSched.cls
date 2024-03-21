global class ResetContatoriSched implements Schedulable{
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new ResetContatoriBatch(), 200);
    }
}