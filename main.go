package main

import (
	"html/template"
	"io"
	"log"
	"net/http"
)

func handler(w http.ResponseWriter, r *http.Request) {
	templateFiles := []string{"templates/base.html", "templates/index.html"}
	t, err := template.ParseFiles(templateFiles...)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	err = t.Execute(w, nil)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
	}

}

func main() {
	http.HandleFunc("/", handler)
	http.Handle("/stylesheets/", http.StripPrefix("/stylesheets/", http.FileServer(http.Dir("vendor/pico/css"))))
	log.Fatal(http.ListenAndServe(":8080", nil))
}

func templateBase(content string, w io.Writer) error {
	t, _ := template.ParseFiles("templates/base.html")
	return t.Execute(w, content)
}
