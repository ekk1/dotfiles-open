use std::cmp::Ordering;
use rand::Rng;
use std::io;

fn main() {
    println!("Guess the number!");

    let secret_num = rand::thread_rng().gen_range(1..=100);

    // println!("The number is {}", secret_num);

    loop {
        println!("Input guess: ");

        let mut guess = String::new();

        io::stdin()
            .read_line(&mut guess) // Use &mut to create mutable ref
            .expect("Failed to read"); // Use expect to handle error simply
                                       // expect is a method on Result type, is Result is Err, panic,
                                       // if Result is Ok, return the value

        let guess: u32 = match guess.trim().parse() {
            Ok(num) => num,
            Err(err) => {
                println!("Illegal input! : {err}");
                continue;
            },
        };

        println!("You guessed: {guess}");

        match guess.cmp(&secret_num) {
            Ordering::Less => println!("Too small!"),
            Ordering::Greater => println!("Too big!"),
            Ordering::Equal => {
                println!("You win!");
                break;
            }
        }
    }
}
