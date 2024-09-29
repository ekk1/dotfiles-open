use gtk4::prelude::*;
use gtk4::{Application, ApplicationWindow, Button};

fn main() {
    // Create a new application
    let app = Application::new(
        Some("com.example.gtk4-demo"),
        Default::default(),
    );

    app.connect_activate(|app| {
        let windows = ApplicationWindow::new(app);

        windows.set_title(Some("GTK4"));
        windows.set_default_size(300, 200);
        // let button = Button::with_label("Click Me!");
        let button = Button::builder()
            .label("Press me!")
            .margin_top(12)
            .margin_bottom(12)
            .build();

        button.connect_clicked(|_| {
            println!("Button clicked!");
        });

        windows.set_child(Some(&button));
        windows.present();

    });

    // Run the application
    app.run();
}
