void main() {
	char *videomem = (char *) 0xb8000;
	*videomem = 'X';
}

