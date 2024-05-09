import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class CompareTextFiles {
    public static void main(String[] args) {
        String file1Path = "test_input.txt";
        String file2Path = "test_output.txt";

        List<Integer> passedTests = new ArrayList<>();
        List<Integer> failedTests = new ArrayList<>();

        try (BufferedReader reader1 = new BufferedReader(new FileReader(file1Path));
             BufferedReader reader2 = new BufferedReader(new FileReader(file2Path))) {
            String line1;
            String line2;
            int lineNumber = 1;

            while ((line1 = reader1.readLine()) != null && (line2 = reader2.readLine()) != null) {
                int value1 = Integer.parseInt(line1);
                int value2 = Integer.parseInt(line2);

                if (Math.abs(value1 - value2) != 10) {
                    System.out.println("Difference not 10 at line " + lineNumber);
                    failedTests.add(lineNumber);
                } else {
                    passedTests.add(lineNumber);
                }

                lineNumber++;
            }

            // Check if both files have the same number of lines
            if (reader1.readLine() != null || reader2.readLine() != null) {
                System.out.println("The files have a different number of lines.");
            } else {
                System.out.println("All lines have a difference of 10.");
            }
        } catch (IOException | NumberFormatException e) {
            e.printStackTrace();
        }

        //System.out.println("Lines that passed tests: " + passedTests);
        System.out.println("Lines that failed tests: " + failedTests);
        System.out.println("Total tests passed: " + passedTests.size());
        System.out.println("Total tests failed: " + failedTests.size());
    }
}
